class Star < ActiveRecord::Base
  has_many :videos
  has_many :user_follow_stars
  has_many :followers, through: :user_follow_stars, source: :user

  validates :name, presence: {message: "姓名不能为空"}

  mount_uploader :avatar, AvatarUploader 
end
