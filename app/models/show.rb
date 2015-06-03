#encoding: UTF-8
class Show < ActiveRecord::Base
  default_scope {order('shows.is_top DESC, shows.created_at DESC')}

  belongs_to :concert
  belongs_to :city
  belongs_to :stadium

  has_many :user_follow_shows
  has_many :show_followers, through: :user_follow_shows, source: :user

  has_many :show_area_relations
  has_many :areas, through: :show_area_relations
  has_many :seats

  has_many :orders
  has_many :tickets

  validates :name, presence: {message: "演出名不能为空"}
  validates :concert, presence: {message: "投票不能为空"}
  validates :stadium, presence: {message: "场馆不能为空"}
  validates :show_time, presence: {message: "演出时间不能为空"}

  scope :is_display, -> { where(is_display: true) }

  before_create :set_city

  after_create :set_status_after_create

  delegate :stars, to: :concert

  enum status: {
    voted_users: 0, #只给有投票的用户购买
    all_users: 1, #全部用户都可以购买
  }

  enum ticket_type: {
    e_ticket: 0, #电子票
    r_ticket: 1, #实体票
  }

  mount_uploader :poster, ImageUploader
  mount_uploader :stadium_map, ImageUploader

  def poster_url
    if poster.url.present?
      if Rails.env.production?
        poster.url("800")
      else
        poster.url
      end
    else
      nil
    end
  end

  def is_display_cn
    if is_display
      "显示"
    else
      "不显示"
    end
  end

  def ticket_type_cn
    case ticket_type
    when "e_ticket"
      "电子票"
    when "r_ticket"
      "实体票"
    end
  end

  def status_cn
    case status
    when "voted_users"
      "只有参与投票的用户才能买"
    when "all_users"
      "全部用户都能购买"
    end
  end

  paginates_per 10

  mount_uploader :poster, ImageUploader

  def topics
    Topic.where("(subject_type = 'Show' and subject_id = ?) or (subject_type = 'Concert' and subject_id = ? and city_id = ?)", self.id, concert_id, city_id)
  end

  def area_seats_left(area)
    valid_tickets = orders.valid_orders.map{|o| o.tickets.where(area_id: area.id)}.flatten
    count = area_seats_count(area) - valid_tickets.count
    count > 0 ? count : 0
  end

  def area_is_sold_out(area)
    show_area_relations.where(area_id: area.id).first.is_sold_out
  end

  def total_seats_count
    show_area_relations.sum(:seats_count)
  end

  def area_seats_count(area)
    show_area_relations.where(area_id: area.id).first.seats_count
  end

  private
  def valids_price
    if min_price.present? && max_price.present?
      errors[:min_price] <<  "最小价格不能大于最大价格" if min_price > max_price
    end
  end

  def set_city
    city = stadium.city
  end

  def set_status_after_create
    self.status = :voted_users if self.status.blank?
    save!
  end

end
