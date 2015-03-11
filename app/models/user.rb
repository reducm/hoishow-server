class User < ActiveRecord::Base
  has_many :orders
  has_many :comments
  has_many :user_follow_stars
  has_many :stars, through: :user_follow_stars  

  has_many :user_follow_concerts
  has_many :concerts, through: :user_follow_concerts

end
