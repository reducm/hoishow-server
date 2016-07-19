#encoding: UTF-8
include QueryExpress
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
  after_commit :set_pay_at, if: :paid?, on: :update

  paginates_per 10

  mount_uploader :ticket_pic, ImageUploader

  delegate :ticket_type, to: :show
  delegate :seat_type, to: :show
  delegate :source, to: :show

  enum status: {
    pending: 0, #未支付
    paid: 1, #已支付
    success: 2, #已出票
    refund: 3, #退款
    outdate: 4, #过期
    refunding: 5 #退款中
  }

  enum channel: {
    hoishow: 0, # Hoishow
    bike_ticket: 1 # 单车电影
  }

  enum ticket_type: {
    e_ticket: 0, #电子票
    r_ticket: 1 #实体票
  }

  scope :valid_orders, ->{ where("status != ?  and status != ?", statuses[:refund], statuses[:outdate]) }
  scope :orders_with_r_tickets, ->{ where("ticket_type = ? and (status = ? or status = ?)", ticket_types[:r_ticket], statuses[:paid], statuses[:success]).order("created_at desc") }
  scope :pending_outdate_orders, ->{ where("created_at < ? and status = ?", Time.now - 15.minutes, statuses[:pending]) }
  scope :today_success_orders, ->{  where("created_at > ? and status = ?", Time.now.at_beginning_of_day, statuses[:success]) }

  # state_machine
  aasm :column => 'status', :whiny_transitions => false do
    state :pending, :initial => true # 调用 CreateOrderLogic
    state :paid
    state :success
    state :refund
    state :outdate
    state :refunding

    # Alipay调用方法 order.pre_pay!({payment_type: 'alipay', trade_id: alipay_params["trade_no"]})
    event :pre_pay, :after => [:set_payment_to_success] do
      transitions :from => :pending, :to => :paid
    end

    # 调用方法 order.success_pay!
    event :success_pay, :after => [:set_tickets_to_success, :set_generate_ticket_time] do
      transitions :from => :paid, :to => :success
    end

    # event :cancel do
    #   transitions :from => :paid, :to => :cancel
    # end

    # 调用方法 order.refunds!({refund_amount: refund_amount, payment: payment, handle_ticket_method: 'refund'})
    event :refunds, :after => [:set_payment_to_refund, :handle_seats_and_tickets] do
      transitions :from => :paid, :to => :refund
    end

    # 调用方法 order.refunds!({refund_amount: refund_amount, payment: payment, handle_ticket_method: 'refund'})
    event :yongle_refunds, :after => [:set_payment_to_refund, :handle_seats_and_tickets] do
      transitions :from => :refunding, :to => :refund
    end

    # 调用方法 order.overtime!({handle_ticket_method: 'outdate'})
    event :overtime, :after => :handle_seats_and_tickets do
      transitions :from => :pending, :to => :outdate
    end
  end

  def area
    show.areas.where(source_id: area_source_id).first
  end

  def area_is_infinite?
    area.present? ? area.is_infinite : false
  end

  def refill_inventory
    # 算库存 如果seats_count为－1每次都要把left_seats补回30
    relation = area.relation
    show = area.show
    old_left_seats = relation.left_seats
    rest_tickets = 30 - old_left_seats

    if rest_tickets > 0
      # sinagle mass insert
      inserts = []
      show_id = show.id
      area_id = area.id
      status = Ticket::statuses[:pending]
      seat_type = Ticket::seat_types[:avaliable]
      price = relation.price
      timenow = Time.now.strftime('%Y-%m-%d %H:%M:%S')
      rest_tickets.times do
        inserts.push "(#{show_id}, #{area_id}, #{status}, #{seat_type}, #{price}, '#{timenow}', '#{timenow}')"
      end
      sql = "INSERT INTO tickets (show_id, area_id, status, seat_type, price, created_at, updated_at) VALUES #{inserts.join(', ')}"
      ActiveRecord::Base.connection.execute sql
      #####################

      relation.update(left_seats: 30)
      area.update(left_seats: 30)
    end
    return true
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

  # 调用此方法需要传入 {handle_ticket_method: 'outdate'} 此参数，表示将 ticket
  # 是 outdate 还是 refund 或者 cancel 处理
  # 然后释放库存或者座位
  def handle_seats_and_tickets *args
    options = args.extract_options!

    begin
      Order.transaction do
        show = self.show
        area_ids = self.tickets.pluck(:area_id)
        # 用 order 里面的 tickets_count
        tickets_count = area_ids.size

        # 这些流程应该还是放到 ticket 的一些 callback 里面比较好
        if show.selected? # 选区则要更新库存
          # 释放 tickets
          self.tickets.update_all(status: Ticket.statuses[:pending],
                                  seat_type: Ticket.seat_types[:avaliable], order_id: nil)

          area_id = area_ids.uniq
          raise RuntimeError, 'area_id not uniq' if area_id.size != 1
          relation = show.show_area_relations.where(area_id: area_id[0]).first
          # update 库存
          if relation.area.is_infinite || relation.left_seats + tickets_count >= 30
            relation.update!(left_seats: 30)
          else
            relation.increment(:left_seats, tickets_count).save!
          end
        elsif show.selectable? # 选座也要更新库存
          # 更新座位信息
          self.tickets.each do |t|
            area = t.area.reload
            sf = area.seats_info
            # 将 ticket 变过期， 如果是退款的话要传入参数
            t.send "#{options[:handle_ticket_method]}!"

            key = t.seat_key
            # 回滚库存
            sf['selled'].delete(key)
            sf['seats'][t.row.to_s][t.column.to_s]['status'] = Area::SEAT_AVALIABLE

            area.update_attributes!(seats_info: sf)
          end

          # 跨区更新库存, 暂时保留
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
  #def self.to_csv(options = {})
  #CSV.generate(options) do |csv|
  #csv << ["订单号", "演出", "下单平台", "下单来源", "门票类型", "下单时间",
  #"付款时间", "购票数量", "总金额", "手机号", "订单状态",
  #"收货人姓名", "收货人电话", "收货人地址", "快递单号"]
  #all.each do |o|
  #if o.show.r_ticket?
  ## 实体票
  #csv << [o.out_id, o.show_name, o.buy_origin, o.channel, o.show.try(:ticket_type_cn), o.created_at_format,
  #o.generate_ticket_at_format, o.tickets_count, o.amount, o.get_username(o.user), o.status_cn,
  #o.user_name, o.user_mobile, o.user_address, o.express_id]
  #else
  ## 电子票
  #csv << [o.out_id, o.show_name, o.buy_origin, o.channel, o.show.try(:ticket_type_cn), o.created_at_format,
  #o.generate_ticket_at_format, o.tickets_count, o.amount, o.get_username(o.user), o.status_cn]
  #end
  #end
  #end
  #end

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
        area = relation.area
        order.ticket_info = "#{area.name} - #{quantity}张"
        order.area_source_id = area.source_id
        order.save!

        # update 库存
        # 加乐观锁
        # ShowAreaRelation.where(id: 1).where("left_seats > ?", 1).first.decrement(:left_seats, 1).save!
        # 效果如 update_all, 不会更新 updated_at
        ActiveRecord::Base.connection.update_sql(<<-EOQ
          UPDATE `show_area_relations`
          SET `left_seats` = `left_seats` - #{quantity}
          WHERE `show_area_relations`.`id` = #{relation.id}
          AND (`show_id` = #{show.id} and `area_id` = #{area.id})
          AND (`left_seats` >= #{quantity} and `left_seats` > 0)
          EOQ
                                                )

        # 更新状态，关联 order
        Ticket.avaliable_tickets.where(area_id: area.id, show_id: show.id,
                                      ).limit(quantity).update_all(seat_type: Ticket.seat_types[:locked], order_id: order.id)

        order
      end
    end

    def init_and_create_tickets_by_seats(show, order_attrs, seats_params, area_id=nil) # area_id 是预留参数
      # p 'start one seat transition'
      Order.transaction do
        # seats_params = { "area_id" => { "row|col" => "price" } }
        # create order
        order = Order.init_from_show(show, order_attrs)

        order.save!
        # count ticket count
        tickets_count = 0
        # set the total_price
        total_price = 0
        # init ticket info
        ticket_info = []
        # 分区处理
        seats_params.each do |area_id, s|
          # raise ActiveRecord::RecordNotFound if area.nil?
          sar = ShowAreaRelation.where(show_id: show.id, area_id: area_id).first
          # 更新 relation 暂时保留
          sar.decrement(:left_seats, s.size).save!
          # load the current area
          area = sar.area.reload
          # load the seats info
          sf = area.select_from_seats_info(s.keys)
          all_seat_info = area.seats_info

          tickets_count += s.size
          total_price += sf.values.map{|item| item['price'].to_i}.sum
          ticket_info += sf.values.map{|item| area.name + ' ' + item['seat_no']}

          # init selled_seats
          selled_seats = []

          # create tickets
          s.each_pair do |k, v|
            row_col = k.split('|')
            Ticket.create(show_id: show.id, area_id: area_id, order_id: order.id,
                          price: sf[k]['price'].to_f, seat_name: sf[k]['seat_no'],
                          row: row_col[0], column: row_col[1])

            # update seat status 相当于更新库存
            all_seat_info['seats'][row_col[0]][row_col[1]]['status'] = Area::SEAT_LOCKED
            selled_seats << k
          end

          # update seats info in area
          all_seat_info.update(selled_seats: selled_seats)
          # all_seat_info['seats'].update(sf)
          # p all_seat_info
          area.update_attributes!(seats_info: all_seat_info)
        end

        update_attrs = {}.tap do |h|
          # set order tickets_count
          h[:tickets_count] = tickets_count
          # set the order amount
          h[:amount] = total_price
          # set the ticket_info
          h[:ticket_info] = ticket_info.join('|')
        end

        order.update_attributes! update_attrs

        order
      end
    end
  end

  # tickets and price warpper
  def set_tickets_and_price(show_area_relations=[])
    # update price
    amount = show_area_relations.map{|relation| relation.price}.inject(&:+)
    self.update_attributes(amount: amount)
    # create_tickets
    self.create_tickets_by_relations(show_area_relations[0], show_area_relations.size)
  end

  def status_outdate?
    if pending? && created_at < Time.now - 15.minutes
      # 状态机
      self.overtime!({handle_ticket_method: 'outdate'})
    end
    outdate?
  end

  def need_refund?
    paid? && created_at < Time.now - 30.minutes
  end

  def already_paid?
    paid? || success? || refund? || refunding?
  end

  def status_cn
    # pending: '未支付'
    # paid: '已支付'
    # success: '已出票'
    # refunding: '退款中'
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

  def pay_at_format
    return nil if self.pay_at.nil?
    pay_at.strftime("%Y年%m月%d日%H:%M")
  end

  def show_time
    show.show_time
  end

  def notify_and_send_sms
    NotifyTicketCheckedWorker.perform_async(open_trade_no)
    if Rails.env.production?
      if r_ticket? && Rails.env.production?
        text = if show.is_presell
                 '您订购的预售门票已支付成功，我们将在公售后的一周内为您发货。届时将会有短信通知，可使用客户端查看订单及跟踪物流信息。客服电话：4008805380【单车娱乐】'
               else
                 '您订购的演出门票已支付成功，我们将在一周内为您发货。届时将会有短信通知，可使用客户端查看订单及跟踪物流信息。客服电话：4008805380【单车娱乐】'
               end
        SendSmsWorker.perform_async(get_user_mobile, text)
      elsif e_ticket? && show.hoishow? # 自有资源电子票短信
        SendSmsWorker.perform_async(get_user_mobile, show.e_ticket_sms + "【单车娱乐】")
      end
    end
  end

  def get_user_name
    user_name || user.show_name
  end

  def get_user_mobile
    user_mobile || user.mobile
  end

  def get_user_address
    user_address || "单车娱乐"
  end

  def yongle_amount
    if ticket_type == 'e_ticket'
      unit_price.to_f * tickets_count
    else
      unit_price.to_f * tickets_count + YongleSetting['postage'].to_i
    end rescue 0
  end

  def dispatch_way
    ticket_type == 'e_ticket' ? 4 : 1
  end

  def add_order_to_yongle
    options = {
      onlineOrderReq: {
        userName: get_user_name,
        phone: get_user_mobile,
        orderAddress: get_user_address,
        created_at: created_at,
        unionOrderList: {
          order: {
            unionOrderId: out_id,
            expressPrice: YongleSetting['postage'],
            ifpay: 1,
            totalFee: yongle_amount,
            dispatchWay: dispatch_way,
            productList: {
              product: {
                productPlayid: area_source_id,
                priceNum: tickets_count
              }
            }
          }
        }
      }
    }
    if dispatch_way == 4
      e_options = {dzp_type: show[:yl_dzp_type]}
      e_options.merge!(IDCard: id_card) if show.idcard?

      options[:onlineOrderReq][:unionOrderList][:order].merge!(e_options)
    end

    YongleService::Service.online_order(options)
  end

  def update_pay_status_to_yongle
    YongleService::Service.update_pay_status(out_id)
  end

  def sync_yongle_status
    result_data = YongleService::Service.find_order_by_unionid_and_orderid(out_id)
    update_by_yongle(result_data) if result_data['result'] == '1000'
  end

  def update_by_yongle(result)
    data = result['data']['Response']['getOrderInfoRsp']['orderInfo']
    Order.transaction do
      options = {
        source_id: data['orderID'],
        status: convert_status(data['orderStarus']),
        express_name: data['expressName'],
        express_id: data['expressNo']
      }

      self.update(options)
    end

    if express_id.present?
      notify_delivery unless self.sms_has_been_sent
    end
  end

  def get_express_name
    if express_name.present?
      express_name
    elsif express_id.present?
      '顺丰速运'
    else
      ''
    end
  end

  def notify_delivery
    SendSmsWorker.perform_async(get_user_mobile, "您订购的演出门票已发货，#{get_express_name}:#{express_id}。可使用客户端查看订单及物流信息。客服电话：4008805380【单车娱乐】")
    self.update(sms_has_been_sent: true)
    NotifyDeliveryWorker.perform_async(open_trade_no) unless Rails.env.test?
  end

  def convert_status(status)
    case status
    when '1',
      Order.statuses['pending']
    when '2', '3', '4'
      Order.statuses['paid']
    when '5', '6'
      Order.statuses['success']
    when '7', '12'
      Order.statuses['outdate']
    when '17', '21'
      Order.statuses['refund']
    else
      Order.statuses['refunding']
    end
  end

  def notify_refund
    url = "#{BikeSetting['notify_refund_url']}?id=#{open_trade_no}"
    begin
      response = RestClient::Request.execute(
          :method => :get,
          :url => url,
          :timeout => 10,
          :open_timeout => 10
      )
      JSON.parse response
    rescue => e
      Rails.logger.fatal("*** errors: #{e.message}")
      nil
    end
  end

  def query_express
    data = get_express_info(express_id)
    update(express_name: data[:delivery_company]) if data
  end

  private
  def set_attr_after_create
    generate_out_id
    self.valid_time = Time.now + 15.minutes
    self.status = :pending if self.status.blank?
    save!
  end

  def generate_out_id
    t = Time.now
    self.out_id = t.strftime('%Y%m%d%H%M') + "OR" + self.id.to_s.rjust(6, '0')
  end

  def set_pay_at
    self.update(pay_at: Time.now) if pay_at.nil?
  end
end
