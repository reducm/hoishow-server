#encoding: UTF-8
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

  validates :user, presence: {message: "用户不能为空"}

  ASSOCIATION_ATTRS = [:city, :concert, :stadium, :show]

  validates_presence_of ASSOCIATION_ATTRS.map{|sym| ( sym.to_s + "_name" ).to_sym}

  after_create :set_attr_after_create

  paginates_per 10

  enum status: {
    pending: 0, #未支付
    paid: 1, #已支付
    success: 2, #已出票
    refund: 3, #退款
    outdate: 4 #过期
  }
  scope :valid_orders, ->{ where("status != ?  and status != ?", statuses[:refund], statuses[:outdate]) }
  scope :orders_with_r_tickets, ->{ where("status = ? or status = ?", statuses[:paid], statuses[:success]) }
  scope :pending_outdate_orders, ->{ where("created_at < ? and status = ?", Time.now - 15.minutes, statuses[:pending]) }
  scope :today_success_orders, ->{  where("created_at > ? and status = ?", Time.now.at_beginning_of_day, statuses[:success]) }

  # state_machine
  aasm :column => 'status', :whiny_transitions => false do
    state :pending, :initial => true # toDo 把 create 后要做的事情可以加进来
    state :paid
    state :success
    state :refund
    state :outdate

    event :pre_pay, :after => :set_payment_to_success do
      transitions :from => :pending, :to => :paid
    end

    event :success_pay, :after => :set_tickets_to_success do
      transitions :from => :paid, :to => :success
    end

    # event :cancel do
    #   transitions :from => :paid, :to => :cancel
    # end

    event :refunds, :after => [:set_payment_to_refund, :set_tickets_to_refund] do
      transitions :from => :success, :to => :refund # 确认是否只能 success 到 refund
    end

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
    payment.update(status: :refund, refund_amount: options[:refund_amount], refund_at: Time.now)
  end

  def set_tickets_to_success *args
  # transaction 这些是否要加 rollback 处理 ?
    begin
      Order.transaction do
        self.tickets.update_all(status: Ticket::statuses['success'])
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
        self.tickets.update_all(status: Ticket::statuses['outdate'])
        self.seats.update_all(status: Seat::statuses['avaliable'])
      end
    rescue => e
      Rails.logger.fatal("*** errors: #{e.message}")
    end
  end

  #创建order时,
  #1. 执行Order.init_from_data(blahblahblah), 把要用到的model扔进来, 方法返回一个new order，未保存到数据库
  #2. new order执行order.set_tickets_and_price(show和area的中间表数组), 例如买三张三区，所以就扔三个三区的中间表数组[show_area_relation, show_area_relation, show_area_relation]
  def self.to_csv(options = {})
    CSV.generate(options) do |csv|
      csv << ["订单号", "演出名称", "用户 / 手机号", "票的类型", "订单时间", "状态", "总价", "收货人姓名", "收货人电话", "收货人地址", "票的状态", "快递单号"]
      all.each do |o|
        csv << [o.out_id, o.show_name, o.get_username(o.user), o.show.try(:ticket_type_cn), o.created_at.try(:strfcn_time), o.status_cn, o.amount]
        if o.show.r_ticket?
          csv << [o.user_name, o.user_mobile, o.user_address, o.express_id]
        end
      end
    end
  end

  class << self
    def init_from_show(show)
      init_from_data(city: show.city, concert: show.concert, show: show, stadium: show.stadium)
    end

    def init_from_data(city: nil, concert: nil, stadium: nil, show: nil )
      #方便把参数_name设到model
      hash = {}
      ASSOCIATION_ATTRS.each do |sym|
        hash[( sym.to_s + "_name" ).to_sym] = eval(sym.to_s).name
        hash[( sym.to_s + "_id" ).to_sym] = eval(sym.to_s).id
      end
      new(hash)
    end
  end

  def create_tickets_by_relations(show_area_relations=[])
    show_area_relations.each do |relation|
      tickets.create(area_id: relation.area_id, show_id: relation.show_id, price: relation.price)
    end
  end

  def create_tickets_by_seats(areas)
    area_ids = areas.map do |a|
      seat_ids << a['seats'].map { |s| s['id'] }
      a['area_id']
    end
    # search all areas in one query
    current_areas = self.show.areas.where(id: area_ids)

    current_areas.each do |area|
      p 'start one seat transition'
      Seat.transaction do
        # search all seats from this area
        area_params = areas.select{ |a| a['area_id'] == area.id}
        seat_ids = area_params[0]['seats'].map { |s| s['id'] }
        p area_params
        p seat_ids
        seats = area.seats.where(id: seat_ids)
        # update each seat
        seats.each do |seat|
          # 先查出来再 lock 需要检验一下是否能行
          seat.with_lock do
            # update seat status
            seat.update(status: :locked, order_id: self.id)
            # create ticket
            self.tickets.create(area_id: seat.area_id, show_id: seat.show_id,
              price: seat.price, seat_name: seat.name)
          end
        end
      end
    end
  end

  # tickets and price warpper
  def set_tickets_and_price(show_area_relations=[])
    # update price
    self.update_attributes(amount: show_area_relations.map{|relation| relation.price}.inject(&:+))
    # create_tickets
    self.create_tickets_by_relations(show_area_relations)
  end

  def tickets_count
    tickets.count
  end

  def status_outdate?
    if pending? && created_at < Time.now - 15.minutes
      # 状态机
      self.overtime!
    end
    outdate?
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

  def show_time
    show.show_time
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
end
