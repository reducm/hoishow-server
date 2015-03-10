class Star < ActiveRecord::Base
  has_many :videos
  has_many :user_follow_stars
  has_many :followers, through: :user_follow_stars, source: :user
end
