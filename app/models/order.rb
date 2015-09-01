#encoding: UTF-8

# out_id        订单号
# remark        备注
# out_trade_no  交易单号
# buy_origin    下单平台: ios, android
# channel       渠道(下单来源): 创建order时的 渠道 参数
# open_trade_no 渠道为非hoishow客户端时才会有, 对应第三方传过来的第三方订单号, 方便对账, 暂时只有单车

class Order < ActiveRecord::Base
  include Operation::OrdersHelper
  include ModelAttrI18n
  include AASM

  belongs_to :user
  #Order创建的时候，要保存concert, stadium,city,show的name和id，用冗余避免多表查询
  belongs_to :show
  belongs_to :stadium
  belongs_to :concert
  belongs_to :city

  has_many :seats
  has_many :tickets, dependent: :destroy
  has_many :payments, -> { where purchase_type: 'Order' }, :foreign_key => 'purchase_id', dependent: :destroy

  # validates :user, presence: {message: "用户不能为空"}

  ASSOCIATION_ATTRS = [:city, :concert, :stadium, :show]

  validates_presence_of ASSOCIATION_ATTRS.map{|sym| ( sym.to_s + "_name" ).to_sym}

  after_create :set_attr_after_create

  paginates_per 10

  delegate :ticket_type, to: :show
  delegate :seat_type, to: :show

  enum status: {
    pending: 0, #未支付
    paid: 1, #已支付
    success: 2, #已出票
    refund: 3, #退款
    outdate: 4 #过期
  }

  enum channel: {
    hoishow: 0, # Hoishow
    bike_ticket: 1 # 单车电影
  }

  enum ticket_type: {
    e_ticket: 0, #电子票
    r_ticket: 1, #实体票
  }

  scope :valid_orders, ->{ where("status != ?  and status != ?", statuses[:refund], statuses[:outdate]) }
  scope :orders_with_r_tickets, ->{ where("ticket_type = ? and (status = ? or status = ?)", ticket_types[:r_ticket], statuses[:paid], statuses[:success]).order("created_at desc") }
  scope :pending_outdate_orders, ->{ where("created_at < ? and status = ?", Time.now - 15.minutes, statuses[:pending]) }
  scope :paid_refund_orders, ->{ where("created_at < ? and status = ?", Time.now - 30.minutes, statuses[:paid]) }
  scope :today_success_orders, ->{  where("created_at > ? and status = ?", Time.now.at_beginning_of_day, statuses[:success]) }

  # state_machine
  aasm :column => 'status', :whiny_transitions => false do
    state :pending, :initial => true # 调用 CreateOrderLogic
    state :paid
    state :success
    state :refund
    state :outdate

    # Wxpay调用方法  order.pre_pay!({payment_type: 'wxpay', trade_id: query_params["transaction_id"]})
    # Alipay调用方法 order.pre_pay!({payment_type: 'alipay', trade_id: alipay_params["trade_no"]})
    event :pre_pay, :after => :set_payment_to_success do
      transitions :from => :pending, :to => :paid
    end

    # 调用方法 order.success_pay!
    event :success_pay, :after => [:set_tickets_to_success, :set_generate_ticket_time] do
      transitions :from => :paid, :to => :success
    end

    # event :cancel do
    #   transitions :from => :paid, :to => :cancel
    # end

    # 调用方法 order.refunds!({refund_amount: refund_amount, payment: payment})
    event :refunds, :after => [:set_payment_to_refund, :set_tickets_to_refund] do
      transitions :from => :success, :to => :refund # 确认是否只能 success 到 refund
    end

    # 调用方法 order.overtime!
    event :overtime, :after => :handle_seats_and_tickets do
      transitions :from => :pending, :to => :outdate
    end
  end

  def set_payment_to_success *args
    options = args.extract_options!
    # 根据类型来找到 payment, alipay 或者 wxpay
    # logger.error() if options[:payment_type].nil?
    query_options = {
      purchase_type: self.class.name,
      purchase_id:   self.id,
      payment_type:  options[:payment_type]
    }

    payment = payments.where(query_options).first
    unless payment.nil?
      payment.update(
        trade_id: options[:trade_id],
        status: :success,
        pay_at: Time.now
      )
    end
  end

  def set_payment_to_refund *args
    options = args.extract_options!

    payment = options[:payment]
    unless payment.nil?
      payment.update(status: :refund, refund_amount: options[:refund_amount], refund_at: Time.now)
    end
  end

  def set_tickets_to_success *args
    # transaction 这些是否要加 rollback 处理 ?
    begin
      Order.transaction do
        self.tickets.each{|t| t.success!}
      end
    rescue => e
      Rails.logger.fatal("*** errors: #{e.message}")
    end
  end

  def set_tickets_to_refund *args
    begin
      Order.transaction do
        self.tickets.update_all(status: Ticket::statuses['refund'])
      end
    rescue => e
      Rails.logger.fatal("*** errors: #{e.message}")
    end
  end

  def handle_seats_and_tickets
    begin
      Order.transaction do
        show = self.show
        area_ids = self.tickets.pluck(:area_id)
        # 用 order 里面的 tickets_count
        tickets_count = area_ids.size
        # 释放 tickets
        self.tickets.update_all(status: Ticket.statuses[:pending],
          seat_type: Ticket.seat_types[:avaliable], order_id: nil)

        # 这些流程应该还是放到 ticket 的一些 callback 里面比较好
        if show.selected? # 选区则要更新库存
          area_id = area_ids.uniq
          raise RuntimeError, 'area_id not uniq' if area_id.size != 1
          relation = show.show_area_relations.where(area_id: area_id[0]).first
          # update 库存
          relation.increment(:left_seats, tickets_count ).save!
        elsif show.selectable? # 选座也要更新库存
          # 跨区选择
          relations = show.show_area_relations.where(area_id: area_ids)

          relations.each do |relation|
            area_id = relation.area_id
            # 如 area_ids = [1, 1, 3]
            # 则 relation area_id 为 1 的库存增加 2, area_id 为 3 的库存增加 1
            # 更新相应的 left_seats 数量
            relation.increment(:left_seats, area_ids.select{ |v| v == area_id }.size).save!
          end
        end
      end
    rescue => e
      Rails.logger.fatal("*** errors: #{e.message}")
    end
  end

  def set_generate_ticket_time
    # 不查询，直接在 set_tickets_to_success
    ticket_status = self.tickets.pluck(:status).uniq
    # 当全部票的状态都为 success
    if ticket_status.size == 1 && ticket_status[0] == Ticket::statuses['success']
      self.update(generate_ticket_at: Time.now)
      notify_and_send_sms
    end
  end

  #创建order时,
  #1. 执行Order.init_from_data(blahblahblah), 把要用到的model扔进来, 方法返回一个new order，未保存到数据库
  #2. new order执行order.set_tickets_and_price(show和area的中间表数组), 例如买三张三区，所以就扔三个三区的中间表数组[show_area_relation, show_area_relation, show_area_relation]
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["订单号", "演出", "下单平台", "下单来源", "门票类型", "下单时间",
              "付款时间", "购票数量", "总金额", "手机号", "订单状态",
              "收货人姓名", "收货人电话", "收货人地址", "快递单号"]
      all.each do |o|
        if o.show.r_ticket?
          # 实体票
          csv << [o.out_id, o.show_name, o.buy_origin, o.channel, o.show.try(:ticket_type_cn), o.created_at_format,
                  o.generate_ticket_at_format, o.tickets_count, o.amount, o.get_username(o.user), o.status_cn,
                  o.user_name, o.user_mobile, o.user_address, o.express_id]
        else
          # 电子票
          csv << [o.out_id, o.show_name, o.buy_origin, o.channel, o.show.try(:ticket_type_cn), o.created_at_format,
                  o.generate_ticket_at_format, o.tickets_count, o.amount, o.get_username(o.user), o.status_cn]
        end
      end
    end
  end

  class << self
    def init_from_show(show, options={})
      init_from_data(city: show.city, concert: show.concert, show: show, stadium: show.stadium, options: options)
    end

    def init_from_data(city: nil, concert: nil, stadium: nil, show: nil, options: {})
      #方便把参数_name设到model
      hash = {}
      ASSOCIATION_ATTRS.each do |sym|
        hash[( sym.to_s + "_name" ).to_sym] = eval(sym.to_s).name
        hash[( sym.to_s + "_id" ).to_sym] = eval(sym.to_s).id
      end
      new(hash.merge(options))
    end

    def init_and_create_tickets_by_relations(show, order_attrs, relation)
      Order.transaction do
        # create order
        quantity = order_attrs[:tickets_count]
        order = Order.init_from_show(show, order_attrs)
        order.ticket_info = "#{relation.area.name} - #{quantity}张"
        order.save!

        # update 库存
        # 加乐观锁
        # ShowAreaRelation.where(id: 1).where("left_seats > ?", 1).first.decrement(:left_seats, 1).save!
        # 效果如 update_all, 不会更新 updated_at
        ActiveRecord::Base.connection.update_sql(<<-EOQ
          UPDATE `show_area_relations`
          SET `left_seats` = `left_seats` - #{quantity}
          WHERE `show_area_relations`.`id` = #{relation.id}
          AND (`show_id` = #{relation.show_id} and `area_id` = #{relation.area_id})
          AND (`left_seats` >= #{quantity} and `left_seats` > 0)
        EOQ
        )

        # 更新状态，关联 order
        Ticket.avaliable_tickets.where(area_id: relation.area_id, show_id: relation.show_id,
          ).limit(quantity).update_all(seat_type: Ticket.seat_types[:locked], order_id: order.id)

        order
      end
    end

    def init_and_create_tickets_by_seats(show, order_attrs, seat_ids)
      # seat_ids = [1, 2, 3, 4] 数组存放 seat 的 id
      # p 'start one seat transition'
      Order.transaction do
        # count ticket count
        quantity = seat_ids.size
        # search all avaliable_tickets
        tickets = show.tickets.avaliable_tickets.where(id: seat_ids)
        # set amount to order
        order_attrs[:amount] = tickets.sum(:price)
        # create order
        order = Order.init_from_show(show, order_attrs)
        order.ticket_info = tickets.map(&:seat_name).join('|')
        order.save!
        # 按 area_id 分组, 或者换种做法
        area_ids_hash = tickets.group(:area_id).count

        raise ArgumentError, 'avaliable_tickets is not enough' if area_ids_hash.values.sum != quantity
        # update ticket
        tickets.update_all(seat_type: Ticket.seat_types[:locked], order_id: order.id)
        # 更新库存，这里可能会有瓶颈
        ShowAreaRelation.where(show_id: show.id, area_id: area_ids_hash.keys).each do |sar|
          sar.decrement(:left_seats, area_ids_hash[sar.area_id]).save!
        end

        order
      end
    end
  end

  # tickets and price warpper
  def set_tickets_and_price(show_area_relations=[])
    # update price
    amount = show_area_relations.map{|relation| relation.price}.inject(&:+)
    amount += postage.to_i
    self.update_attributes(amount: amount)
    # create_tickets
    self.create_tickets_by_relations(show_area_relations[0], show_area_relations.size)
  end

  def status_outdate?
    if pending? && created_at < Time.now - 15.minutes
      # 状态机
      self.overtime!
    end
    outdate?
  end

  def need_refund?
    paid? && created_at < Time.now - 30.minutes
  end

  def already_paid?
    paid? || success? || refund?
  end

  def status_cn
    # pending: '未支付'
    # paid: '已支付'
    # success: '已出票'
    # refund: '已退款'
    # outdate: '已过期'
    tran("status")
  end

  def payment_body
    "#{stadium_name}-#{show_name}-#{show_time_format}-#{tickets_count}张"
  end

  def show_time_format
    return nil if self.show_time.nil?
    show_time.strftime("%Y年%m月%d日%H:%M")
  end

  def created_at_format
    return nil if self.created_at.nil?
    created_at.strftime("%Y年%m月%d日%H:%M")
  end

  def generate_ticket_at_format
    return nil if self.generate_ticket_at.nil?
    generate_ticket_at.strftime("%Y年%m月%d日%H:%M")
  end

  def show_time
    show.show_time
  end

  def notify_and_send_sms
    NotifyTicketCheckedWorker.perform_async(open_trade_no)
    ChinaSMS.to(user.mobile, '【单车娱乐】亲爱的单车用户，您订购的演出门票已出票，我们将尽快为您配送。可使用客户端查看订单及跟踪物流信息。客服电话：4008805380')
  end

  private
  def set_attr_after_create
    generate_out_id
    self.valid_time = Time.now + 15.minutes
    self.status = :pending if self.status.blank?
    self.postage = CommonData.get_value('postage')
    save!
  end

  def generate_out_id
    t = Time.now
    self.out_id = t.strftime('%Y%m%d%H%M') + "OR" + self.id.to_s.rjust(6, '0')
  end
end
