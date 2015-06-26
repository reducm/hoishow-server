#encoding: UTF-8
class Order < ActiveRecord::Base
  include Operation::OrdersHelper

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

  def set_tickets_and_price(show_area_relations=[])
    self.amount = show_area_relations.map{|relation| relation.price}.inject(&:+)
    save!
    show_area_relations.each do |relation|
      tickets.create(area_id: relation.area_id, show_id: relation.show_id, price: relation.price)
    end
  end

  def set_tickets_info(seat)
    tickets.create(area_id: seat.area_id, show_id: seat.show_id, price: seat.price, seat_name: seat.name)
  end

  def set_tickets
    begin
      Order.transaction do
        tickets.update_all(status: Ticket::statuses['success'])
        self.success!
      end
    rescue => e
      Rails.logger.fatal("*** errors: #{e.message}")
      nil
    end
  end

  def refund_tickets
    tickets.update_all(status: Ticket::statuses['refund'])
  end

  def tickets_count
    tickets.count
  end

  def status_outdate?
    if pending? && created_at < Time.now - 15.minutes
      outdate!
      outdate_others
    end
    outdate?
  end

  def outdate_others
    tickets.update_all(status: Ticket::statuses['outdate'])
    seats.update_all(status: Seat::statuses['avaliable'])
  end

  def already_paid?
    paid? || success? || refund?
  end

  def status_cn
    case status
    when 'pending'
      '未支付'
    when 'paid'
      '已支付'
    when 'success'
      '已出票'
    when 'refund'
      '已退款'
    when 'outdate'
      '已过期'
    end
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

  def alipay_pay
    query_options = {
      purchase_type: self.class.name,
      purchase_id:   self.id,
      payment_type:  "alipay"
    }

    payment = payments.where(query_options).first
  end

  def wxpay_pay
    query_options = {
      purchase_type: self.class.name,
      purchase_id:   self.id,
      payment_type:  "wxpay"
    }

    payment = payments.where(query_options).first
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
