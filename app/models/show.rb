class Show < ActiveRecord::Base
  belongs_to :concert
  belongs_to :city
  belongs_to :stadium

  has_many :show_area_relations
  has_many :areas, through: :show_area_relations

  validates :name, presence: {message: "Show名不能为空"}
  validates :concert, presence: {message: "Concert不能为空"}
  validates :stadium, presence: {message: "Stadium不能为空"}
  validate :valids_price

  before_create :set_city

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
