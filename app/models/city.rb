class City < ActiveRecord::Base
  has_many :stadiums
  has_many :shows

  has_many :concert_city_relations
  has_many :concerts, through: :concert_city_relations
end
