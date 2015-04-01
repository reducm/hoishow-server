class City < ActiveRecord::Base
  has_many :districts
  has_many :shows

  has_many :concert_city_relations
  has_many :concerts, through: :concert_city_relations

  has_many :topics

  validates :name, presence: {message: "城市名字不能为空"}, uniqueness: {message: "城市名字不能重复"}

  def stadiums
    district_ids = districts.pluck(:id)
    Stadium.where(district_id: district_ids)
  end
end
