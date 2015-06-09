class UserVoteConcert < ActiveRecord::Base
  belongs_to :user
  belongs_to :concert
  belongs_to :city
  validates_presence_of :user_id, :concert_id, :city_id
  validates_uniqueness_of :user_id, scope: [:concert_id]
  scope :today_votes, ->{  where("created_at > ?", Time.now.at_beginning_of_day) }
end
