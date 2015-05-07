class Show < ActiveRecord::Base
  belongs_to :concert
  belongs_to :city
  belongs_to :stadium

  has_many :user_follow_shows
  has_many :show_followers, through: :user_follow_shows, source: :user

  has_many :show_area_relations
  has_many :areas, through: :show_area_relations
  has_many :orders
  has_many :tickets

  validates :name, presence: {message: "Show名不能为空"}
  validates :concert, presence: {message: "Concert不能为空"}
  validates :stadium, presence: {message: "Stadium不能为空"}
  #validate :valids_price

  before_create :set_city

  after_create :set_status_after_create

  delegate :stars, to: :concert

  enum status: {
    voted_users: 0, #只给有投票的用户购买
    all_users: 1, #全部用户都可以购买
  }

  def status_cn
    case status
    when "voted_users"
      "只有参与投票的用户才能买"
    when "all_users"
      "全部用户都能购买"
    end
  end

  paginates_per 20

  mount_uploader :poster, ImageUploader

  def topics
    Topic.where(city_id: city.id, subject_type: Concert.name, subject_id: concert.id)
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
    areas.sum(:seats_count)
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
