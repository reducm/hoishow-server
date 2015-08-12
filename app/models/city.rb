#encoding: UTF-8
class City < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.week)

  has_many :stadiums
  has_many :shows

  has_many :concert_city_relations
  has_many :concerts, through: :concert_city_relations

  has_many :topics

  validates :name, presence: {message: "城市名字不能为空"}, uniqueness: {message: "城市名字不能重复"}

  paginates_per 10

  def hold_concert(concert)
    concert_city_relations.where(concert: concert).first_or_create!
  end

  def stadiums_count
    stadiums.count
  end
end
