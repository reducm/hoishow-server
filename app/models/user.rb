#encoding: UTF-8
class User < ActiveRecord::Base
  has_many :orders
  has_many :comments

  has_many :topics, :class_name => "Topic", :foreign_key => 'creator_id'

  has_many :user_follow_stars
  has_many :follow_stars, through: :user_follow_stars, source: :star

  has_many :user_follow_concerts
  has_many :follow_concerts, through: :user_follow_concerts, source: :concert

  has_many :user_vote_concerts
  has_many :vote_concerts, through: :user_vote_concerts, source: :concert

  has_many :user_like_topics
  has_many :like_topics, through: :user_like_topics, source: :topic

  validates :mobile, presence: {message: "手机号不能为空"}, format: { with: /^0?(13[0-9]|15[012356789]|18[0-9]|17[0-9]|14[57])[0-9]{8}$/, multiline: true, message: "手机号码有误"}, uniqueness: true

  mount_uploader :avatar, ImageUploader

  paginates_per 20

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

  def unfollow_star(star)
    if destroy_star = user_follow_stars.where(star_id: star.id).first
      destroy_star.destroy!
    end
  end

  def unfollow_concert(concert)
    if destroy_concert = user_follow_concerts.where(concert_id: concert.id).first
      destroy_concert.destroy!
    end
  end

  def create_comment(topic, parent_id = nil, content)
    comments.create(topic_id: topic.id, parent_id: parent_id, content: content)
  end

  def vote_concert(concert, city)
    user_vote_concerts.where(concert_id: concert.id, city_id: city.id).first_or_create!
  end

  def like_topic(topic)
    user_like_topics.where(topic_id: topic.id).first_or_create!
  end

  def show_name
    nickname || encode_mobile
  end

  def encode_mobile
    a = self.mobile
    a[3..6] = "****"
    a
  end

 class << self
    def find_mobile(mobile="")
      where(mobile: mobile).first_or_create!
    end
  end
end
