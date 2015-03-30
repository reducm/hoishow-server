#encoding: UTF-8
class User < ActiveRecord::Base
  has_many :orders
  has_many :comments

  has_many :user_follow_stars
  has_many :follow_stars, through: :user_follow_stars, source: :star

  has_many :user_follow_concerts
  has_many :follow_concerts, through: :user_follow_concerts, source: :concert

  has_many :user_vote_concerts
  has_many :vote_concerts, through: :user_vote_concerts, source: :concert

  validates :mobile, presence: {message: "手机号不能为空"}, format: { with: /^0?(13[0-9]|15[012356789]|18[0-9]|17[0-9]|14[57])[0-9]{8}$/, multiline: true, message: "手机号码有误"}, uniqueness: true 

  mount_uploader :avatar, AvatarUploader 

  enum sex: {
    male: 0,
    female: 1,
    secret: 2
  }

  def sign_in_api
    return if self.api_token.present? && self.api_expires_in.present?
    
    self.api_token = SecureRandom.hex(16)
    self.api_expires_in = 1.years
    save!
  end

  def follow_star(star)
    user_follow_stars.where(star_id: star.id).first_or_create!
  end

  def follow_concert(concert)
    user_follow_concerts.where(concert_id: concert.id).first_or_create!
  end

  def vote_concert(concert, city)
    user_vote_concerts.where(concert_id: concert.id, city_id: city.id).first_or_create!
  end

 class << self
    def find_mobile(mobile="")
      where(mobile: mobile).first_or_create!
    end
  end
end
