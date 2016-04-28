#encoding: UTF-8
class Show < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.week)

  include ModelAttrI18n
  belongs_to :concert
  belongs_to :city
  belongs_to :stadium

  has_many :user_follow_shows
  has_many :show_followers, through: :user_follow_shows, source: :user

  has_many :events, dependent: :destroy
  has_many :show_area_relations, dependent: :destroy
  has_many :areas, through: :show_area_relations
  has_many :seats

  has_many :orders
  has_many :tickets

  validates :name, presence: {message: "演出名不能为空"}
  validates :source, presence: {message: "资源方不能为空"}
  validates :concert, presence: {message: "投票不能为空"}
  validates :stadium, presence: {message: "场馆不能为空"}

  scope :is_display, -> { where(is_display: true).order('shows.is_top DESC, shows.created_at DESC') }

  before_create :set_city

  after_create :set_status_after_create
  after_create :set_mode_after_create

  delegate :stars, to: :concert

  # 永乐电子票类型
  enum yl_dzp_type: {
    onedcode: 0, # 一维码
    qrcode: 1, # 二维码
    idcard: 2 # 身份证
  }

  # 演出资源提供方
  enum source: {
    hoishow: 0, # 自有资源
    damai: 1, # 大麦
    yongle: 2, # 永乐
    weipiao: 3, # 微票
    viagogo: 4 # viagogo
  }

  enum mode: {
    voted_users: 0, #只给有投票的用户购买
    all_users: 1, #全部用户都可以购买
  }

  enum status: {
    selling: 0, #售票中
    sell_stop: 1, #售票结束
    going_to_open: 2, #即将开放
  }

  enum ticket_type: {
    e_ticket: 0, #电子票
    r_ticket: 1, #实体票
  }

  enum seat_type: {
    selectable: 0, #可以选座
    selected: 1, #只能选区
  }

  paginates_per 10

  mount_uploader :ticket_pic, ImageUploader
  mount_uploader :poster, ImageUploader
  mount_uploader :stadium_map, ImageUploader

  # 避免保存到mysql时遇到的4字节字符问题
  def description=(value)
    write_attribute(:description, Base64.encode64(value))
  end

  def description
    Base64.decode64(read_attribute(:description)).force_encoding("utf-8")
  end
  #################################

  def is_upcoming?
    showtime = events.verified.first.try(:show_time)
    showtime.present? ? showtime <= DateTime.now + 7 : false
  end

  def self.is_upcoming
    ##### 找出符合条件的event
    # events = Event.verified.where("show_time <= ?", DateTime.now + 7)
    ##### 找出event的show_id
    # events.select(:show_id).group(:show_id).count
    # { 682=>7, 159=>7, 132=>7, ... }
    show_ids = Event.verified.where("show_time <= ?", DateTime.now + 7).select(:show_id).group(:show_id).pluck(:show_id)
    Show.where(id: show_ids)
  end

  def self.is_not_upcoming
    show_ids = Event.verified.where("show_time > ?", DateTime.now + 7).select(:show_id).group(:show_id).pluck(:show_id)
    Show.where(id: show_ids)
  end

  def self.finished_shows
    Show.where.not(source: 0, status: 1).select{|show| show.events.any? && show.events.last.show_time < Time.now + 3.days}
  end

  # 该区域已出票，但订单未支付的票数
  def unpaid_tickets_count(area_id)
    if orders.any?
      area = Area.find(area_id)
      this_area_order_ids = area.tickets.success.pluck(:order_id).uniq
      orders.where(id: this_area_order_ids).pending.sum(:tickets_count)
    else
      0
    end
  end

  # 该区域已出票，并且订单已支付的票数
  def sold_tickets_count(area_id)
    if orders.any?
      area = Area.find(area_id)
      this_area_order_ids = area.tickets.success.pluck(:order_id).uniq
      orders.where(id: this_area_order_ids).success.sum(:tickets_count)
    else
      0
    end
  end

  def get_show_time
    if going_to_open?
      description_time
    else
      show_time.strfcn_date
    end
  end

  def source_cn
    # hoishow: "自有资源"
    # damai: "大麦"
    # yongle: "永乐"
    # weipiao: "微票"
    tran("source")
  end

  def is_display_cn
    # is_display ? "显示" : "隐藏"
    tran("is_display")
  end

  def is_presell_cn
    # is_presell ? "预售" : "在售"
    tran("is_presell")
  end

  def ticket_type_cn
    # e_ticket: "电子票"
    # r_ticket: "实体票"
    tran("ticket_type")
  end

  def seat_type_cn
    # selectable: "可以选座"
    # selected: "只能选区"
    tran("seat_type")
  end

  def mode_cn
    # voted_users: "只有参与投票的用户才能买"
    # all_users: "全部用户都能购买"
    tran("mode")
  end

  def status_cn
    # selling: "开放购票中"
    # sell_stop: "购票结束"
    # going_to_open: "即将开放"
    tran("status")
  end

  def topics
    Topic.where("(subject_type = 'Show' and subject_id = ?) or (subject_type = 'Concert' and subject_id = ? and city_id = ?)", self.id, concert_id, city_id)
  end

  def area_seats_left(area_id)
    # find all valid tickets
    # valid_tickets_count = area.tickets.where(order_id: self.orders.valid_orders.pluck(:id)).count
    # find the seats_count in this area
    # count = area_seats_count(area) - valid_tickets_count

    # [0, count].max
    relation = self.show_area_relations.where(area_id: area_id).first
    relation.try(:left_seats) || 0
  end

  def area_is_sold_out(area_id)
    show_area_relations.where(area_id: area_id).first.is_sold_out
  end

  def total_seats_count
    show_area_relations.sum(:seats_count)
  end

  def area_seats_count(area_id)
    if seats_count = show_area_relations.where(area_id: area_id).first.seats_count
      seats_count
    else
      0
    end
  end

  def get_show_base_number
    if relation = ConcertCityRelation.where(concert_id: self.concert_id, city_id: self.city_id).first
      relation.base_number
    else
      0
    end
  end

  def voters_count
    UserVoteConcert.where(concert_id: concert_id, city_id: city_id).count + get_show_base_number
  end

  def first_star
    stars.first
  end

  def price_array
    price_array = if selected?
                    show_area_relations.map{|relation| relation.price.to_i}
                  elsif selectable?
                    areas.map(&:all_price_with_seats).flatten
                  else
                    []
                  end

    price_array = price_array.uniq.sort if price_array.present?
  end

  def min_price
    if price_array.size <= 1
      price_array.first.to_i.to_s
    else
      price_array.first
    end
  end

  def max_price
    if price_array.size <= 1
      price_array.first.to_i.to_s
    else
      price_array.last
    end
  end

  def get_price_range
    if min_price == max_price
      min_price
    else
      "#{min_price} - #{max_price}"
    end
  end

  def event_show_time
    showtime = events.verified.first.try(:show_time)
    return nil if showtime.nil?
    showtime.strftime("%Y年%m月%d日%H:%M")
  end

  def star_names
    stars.pluck(:name).join(",")
  end

  def ticket_pic_url_for_danche
    if self.viagogo?
      #直传地址
      "http://hoishow-img.b0.upaiyun.com/uploads/nba/img/5f91390ff56ed052466d87f65fd82182.png"
    else
      ticket_pic_url
    end
  end

  def poster_url_for_danche
    if self.viagogo?
      ( poster_url + "!sportsposter" ) rescue ''
    else
      poster_url
    end
  end

  def play_type
    if yongle?
      pt = YlPlayType.where(play_type_a_id: yl_play_type_a_id, play_type_b_id: yl_play_type_b_id).first
      pt.play_type_a
    elsif viagogo? #TODO 等待创建字段
      case show_type
      when 'Concert', 'Festival'
        '演唱会'
      when 'Theatre'
        '音乐会'
      else
        show_type
      end
    end
  end

  private
  def set_city
    city = stadium.city
  end

  def set_status_after_create
    self.status = :selling if self.status.blank?
    save!
  end

  def set_mode_after_create
    if self.concert.auto_hide?
      self.mode = :all_users
    elsif self.mode.blank?
      self.mode = :voted_users
    end
    save!
  end
end
