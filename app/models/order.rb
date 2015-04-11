#encoding: UTF-8
class Order < ActiveRecord::Base
  belongs_to :user
  #Order创建的时候，要保存concert, stadium,city,show的name和id，用冗余避免多表查询
  #
  belongs_to :show
  has_many :tickets

  validates :user, presence: {message: "User不能为空"}

  ASSOCIATION_ATTRS = [:city, :concert, :stadium, :show]

  validates_presence_of ASSOCIATION_ATTRS.map{|sym| ( sym.to_s + "_name" ).to_sym}

  after_create :set_attr_after_create

  enum status: {
    pending: 0, #未支付
    paid: 1, #已支付
    success: 2, #已出票
    refund: 3, #退款
    outdate: 4 #过期
  }
  scope :valid_orders, ->{ where("status != ?  and status != ?", statuses[:refund], statuses[:outdate]) }
  scope :pending_outdate_orders, ->{ where("created_at < ? and status = ?", Time.now - 15.minutes, Order.statuses[:pending]) }

  #创建order时,
  #1. 执行Order.init_from_data(blahblahblah), 把要用到的model扔进来, 方法返回一个new order，未保存到数据库
  #2. new order执行order.set_tickets_and_price(show和area的中间表数组), 例如买三张三区，所以就扔三个三区的中间表数组[show_area_relation, show_area_relation, show_area_relation]
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

  def tickets_count
    tickets.count
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
