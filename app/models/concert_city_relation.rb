#encoding: UTF-8
class ConcertCityRelation < ActiveRecord::Base
  belongs_to :concert
  belongs_to :city

  validates_uniqueness_of :city_id, scope: [:concert_id]
end
