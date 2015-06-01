#encoding: UTF-8
class ConcertCityRelation < ActiveRecord::Base
  belongs_to :concert
  belongs_to :city
end
