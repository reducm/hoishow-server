class ConcertCityRelation < ActiveRecord::Base
  belongs_to :concert
  belongs_to :city
end
