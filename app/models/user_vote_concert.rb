class UserVoteConcert < ActiveRecord::Base
  belongs_to :user
  belongs_to :concert
  belongs_to :city
  validates_presence_of :user_id, :concert_id, :city_id
end
