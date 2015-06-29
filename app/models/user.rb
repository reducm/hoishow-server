#encoding: UTF-8
class User < ActiveRecord::Base
  include Operation::ApplicationHelper
  has_many :orders
  has_many :expresses

  has_many :comments, -> { where creator_type: Comment::CREATOR_USER }, :foreign_key => 'creator_id'
  has_many :topics, -> { where creator_type: Topic::CREATOR_USER }, :foreign_key => 'creator_id'

  has_many :user_follow_stars
  has_many :follow_stars, through: :user_follow_stars, source: :star

  has_many :user_follow_concerts
  has_many :follow_concerts, through: :user_follow_concerts, source: :concert

  has_many :user_follow_shows
  has_many :follow_shows, through: :user_follow_shows, source: :show

  has_many :user_vote_concerts
  has_many :vote_concerts, through: :user_vote_concerts, source: :concert

  has_many :user_like_topics
  has_many :like_topics, through: :user_like_topics, source: :topic

  has_many :user_message_relations
  has_many :messages, through: :user_message_relations, source: :message

  validates :mobile, presence: {message: "手机号不能为空"}, format: { with: /^0?(13[0-9]|15[012356789]|18[0-9]|17[0-9]|14[57])[0-9]{8}$/, multiline: true, message: "手机号码有误"}, uniqueness: true

  mount_uploader :avatar, ImageUploader

  paginates_per 10

  enum sex: {
    male: 0,
    female: 1,
    secret: 2
  }

  scope :today_registered_users, ->{ where("created_at > ?", Time.now.at_beginning_of_day) }

  def sex_cn
    # male: '男'
    # female: '女'
    # secret: '保密'
    tran("sex")
  end

  def avatar_url
    if avatar.url.present?
      if Rails.env.production?
        avatar.url("avatar")
      else
        avatar.url
      end
    else
      nil
    end
  end

  def sign_in_api
    return if self.api_token.present? && self.api_expires_in.present?

    self.api_token = SecureRandom.hex(16)
    self.api_expires_in = 1.years
    self.last_sign_in_at = DateTime.now
    save!
  end

  def display_orders
    orders.where("orders.status != ?", 4).order('created_at desc')
  end

  def page_orders(page = 1, per = 10)
    display_orders.page(page).per(per)
  end

  def follow_star(star)
    user_follow_stars.where(star_id: star.id).first_or_create!
  end

  def follow_concert(concert)
    user_follow_concerts.where(concert_id: concert.id).first_or_create!
  end

  def follow_show(show)
    user_follow_shows.where(show_id: show.id).first_or_create!
  end

  def unfollow_show(show)
    if destroy_show = user_follow_shows.where(show_id: show.id).first
      destroy_show.destroy!
    end
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
    comment = comments.create(topic_id: topic.id, parent_id: parent_id, content: Base64.encode64(content))
    if comment
      r_content = remove_emoji_from_content(content)
      if parent_id
        #回覆评论
        r_comment = Comment.find(parent_id)
        if r_comment.creator_type == "User" &&  r_comment.creator != self
          creator = r_comment.creator
          title = comment.creator.show_name + "回复了你的评论"
          message = Message.create(send_type: "comment_reply", creator_type: "User", creator_id: self.id, subject_type: "Topic", subject_id: topic.id, title: "你有新的回覆", content: r_content)
          creator.user_message_relations.where(message: message).first_or_create!
          message.send_message_for_reply_comment(creator.mobile, title, message.content)
        end
      end
      if topic.creator_type == "User" && topic.creator != self
        message = Message.create(send_type: "topic_reply", creator_type: "User", creator_id: self.id, subject_type: "Topic", subject_id: topic.id, title: "你有新的回覆", content: r_content)
        topic.creator.user_message_relations.where(message: message).first_or_create!
      end
    end
    comment
  end

  def vote_concert(concert, city)
    if vote_concert = user_vote_concerts.where(concert_id: concert.id).first
      vote_concert.destroy!
    end

    user_vote_concerts.where(concert_id: concert.id, city_id: city.id).first_or_create!
    user_follow_concerts.where(concert_id: concert.id).first_or_create!
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

    def search(q)
      where("nickname like ? or mobile like ?", "%#{q}%", "%#{q}%")
    end
  end
end
