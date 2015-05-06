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
    hidden: 0, #隐藏不显示的show
    voted_users: 1, #只给有投票的用户购买
    all_users: 2, #全部用户都可以购买
  }


  paginates_per 20

  mount_uploader :poster, ImageUploader

  def topics
    Topic.where(city_id: city.id, subject_type: Concert.name, subject_id: concert.id)
  end

  def area_seats_left(area)
    valid_tickets = orders.valid_orders.map{|o| o.tickets.where(area_id: area.id)}.flatten
    relation = show_area_relations.where(area_id: area.id).first
    count = relation.seats_count - valid_tickets.count
    count > 0 ? count : 0
  end

  def area_is_sold_out(area)
    show_area_relations.where(area_id: area.id).first.is_sold_out
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
