#encoding: UTF-8
class StarConcertRelation < ActiveRecord::Base
  belongs_to :star
  belongs_to :concert
end
