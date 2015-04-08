class Show < ActiveRecord::Base
  belongs_to :concert
  belongs_to :city
  belongs_to :stadium

  has_many :show_area_relations
  has_many :areas, through: :show_area_relations
  has_many :orders
  has_many :tickets

  validates :name, presence: {message: "Show名不能为空"}
  validates :concert, presence: {message: "Concert不能为空"}
  validates :stadium, presence: {message: "Stadium不能为空"}
  validate :valids_price

  before_create :set_city

  delegate :stars, to: :concert

  paginates_per 20

  mount_uploader :poster, PosterUploader 

  def topics
    Topic.where(city_id: city.id, subject_type: Concert.name, subject_id: concert.id)
  end

  def area_seats_left(area)
    valid_tickets = orders.valid_orders.map{|o| o.tickets.where(area_id: area.id)}.flatten
    count = area.seats_count - valid_tickets.count
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
end
