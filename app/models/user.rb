#encoding: UTF-8
class User < ActiveRecord::Base
  acts_as_cached(:version => 1, :expires_in => 1.week)

  include Operation::ApplicationHelper
  include ModelAttrI18n

  has_many :orders
  has_many :expresses

  has_many :comments, -> { where creator_type: Comment::CREATOR_USER }, :foreign_key => 'creator_id'
  has_many :topics, -> { where creator_type: Topic::CREATOR_USER }, :foreign_key => 'creator_id'

  #----------------boombox
  has_many :user_follow_collaborators, dependent: :destroy
  has_many :follow_collaborators, through: :user_follow_collaborators, source: :collaborator

  has_many :user_follow_playlists, dependent: :destroy
  has_many :follow_playlists, through: :user_follow_playlists, source: :boom_playlist

  has_many :boom_user_likes, dependent: :destroy
  has_many :boom_like_comments, through: :boom_user_likes, source: :subject, source_type: BoomComment.name
  has_many :boom_like_topics, through: :boom_user_likes, source: :subject, source_type: BoomTopic.name

  has_many :boom_playlists, -> { where creator_type: BoomPlaylist::CREATOR_USER }, foreign_key: 'creator_id'

  has_many :boom_comments, -> { where creator_type: BoomComment::CREATOR_USER }, foreign_key: "creator_id"

  has_many :user_track_relations, dependent: :destroy

  has_many :boom_feedbacks

  has_many :boom_user_message_relations, dependent: :destroy
  has_many :boom_messages, through: :boom_user_message_relations, source: :boom_message
  #----------------boombox

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

  #validates :mobile, presence: {message: "手机号不能为空"}, format: { with: /^0?(13[0-9]|15[012356789]|18[0-9]|17[0-9]|14[57])[0-9]{8}$/, multiline: true, message: "手机号码有误"}, uniqueness: true
  validates :bike_user_id, presence: {message: "bike_ticket 渠道 bike_user_id 不能为空"}, if: :is_bike_ticket?
  after_create :set_default_playlist
  mount_uploader :avatar, ImageUploader

  paginates_per 10

  enum sex: {
    male: 0,
    female: 1,
    secret: 2
  }

  enum channel: {
    ios: 0,
    android: 1,
    bike_ticket: 2 # 单车电影
  }

  scope :today_registered_users, ->{ where("created_at > ?", Time.now.at_beginning_of_day) }
  # hoishow用户
  scope :from_hoishow, ->{ where("boom_id IS NULL") }
  # 播霸用户
  scope :from_boombox, ->{ where("boom_id IS NOT NULL") }

  def sex_cn
    # male: '男'
    # female: '女'
    # secret: '保密'
    tran("sex")
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

  #----------------------boombox
  def follow_collaborator(collaborator)
    user_follow_collaborators.where(collaborator_id: collaborator.id).first_or_create!
  end

  def unfollow_collaborator(collaborator)
    if destroy_collaborator = user_follow_collaborators.where(collaborator_id: collaborator.id).first
      destroy_collaborator.destroy!
    end
  end

  def follow_boomplaylist(playlist)
    user_follow_playlists.where(boom_playlist_id: playlist.id).first_or_create!
  end

  def unfollow_boomplaylist(playlist)
    if destroy_playlist = user_follow_playlists.where(boom_playlist_id: playlist.id).first
      destroy_playlist.destroy!
    end
  end

  def like_boomtopic(topic)
    boom_user_likes.where(subject_type: BoomUserLike::SUBJECT_TOPIC, subject_id: topic.id).first_or_create!
  end

  # 点赞时间
  def like_boomtopic_at(topic)
    boom_user_likes.where(subject_type: BoomUserLike::SUBJECT_TOPIC, subject_id: topic.id).first.created_at
  end

  def unlike_boomtopic(topic)
    if destroy_topic = boom_user_likes.where(subject_type: BoomUserLike::SUBJECT_TOPIC, subject_id: topic.id).first
      destroy_topic.destroy!
    end
  end

  def like_boomcomment(comment)
    boom_user_likes.where(subject_type: BoomUserLike::SUBJECT_COMMENT, subject_id: comment.id).first_or_create!
  end

  def unlike_boomcomment(comment)
    if destroy_comment = boom_user_likes.where(subject_type: BoomUserLike::SUBJECT_COMMENT, subject_id: comment.id).first
      destroy_comment.destroy!
    end
  end

  def recommend_tags
    Rails.cache.fetch("user:#{id}:recommend_tags", expires_in: 1.day) do
      track_ids = user_track_relations.order('play_count desc').limit(3).pluck(:boom_track_id).uniq
      tag_ids = TagSubjectRelation.where(subject_type: TagSubjectRelation::SUBJECT_TRACK, subject_id: track_ids).pluck(:boom_tag_id).uniq
      BoomTag.where(id: tag_ids)
    end
  end

  def recommend_tracks
    Rails.cache.fetch("user:#{id}:recommend_tracks", expires_in: 1.day) do
      recommend_tags.map{|tag| tag.tracks}.flatten.uniq.shuffle.first(20)
    end
  end

  def recommend_playlists
    Rails.cache.fetch("user:#{id}:recommend_playlists", expires_in: 1.day) do
      recommend_tags.map{|tag| tag.playlists.playlist}.flatten.uniq.shuffle.first(10)
    end
  end

  def recommend_radios
    Rails.cache.fetch("user:#{id}:recommend_playlists", expires_in: 1.day) do
      recommend_tags.map{|tag| tag.playlists.radio}.flatten.uniq.shuffle.first(10)
    end
  end
  #----------------------boombox

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
          message.push(creator.mobile, '你有新的回复', title, message.content)
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

  def is_bike_ticket?
    self.channel == 'bike_ticket'
  end

  class << self
    def find_mobile(mobile="")
      where(mobile: mobile).first_or_create!
    end

    def search(q)
      where("nickname like ? or mobile like ?", "%#{q}%", "%#{q}%")
    end

    def find_or_create_bike_user(mobile="", bike_user_id) # 创建单车电影过来的用户
      channel = self.channels[:bike_ticket]
      bike_user = self.where(bike_user_id: bike_user_id).first

      if bike_user.nil? # hoishow 不存在该 bike_user_id 的用户
        # 查询是否存在这个电话号码的用户
        hoishow_user = self.where(mobile: mobile).first

        if hoishow_user.nil?
          # 不存在则创建新用户
          return_user = self.create(mobile: mobile, bike_user_id: bike_user_id, channel: channel)
        else
          # 存在则关联到本地用户
          hoishow_user.update_attributes(bike_user_id: bike_user_id)
          return_user = hoishow_user
        end
      else
        if bike_user.mobile != mobile && bike_user.channel == 'bike_ticket'
          # 渠道为单车电影的用户电话号码有修改, 则修改该用户的电话号码，其他渠道暂时不修改电话号码
          bike_user.update_attributes(mobile: mobile)
        end
        return_user = bike_user
      end

      return_user
    end
  end

  def set_password(password)
    self.salt = SecureRandom.base64(24)
    pbkdf2 = OpenSSL::PKCS5::pbkdf2_hmac_sha1(password, self.salt, 1000, 24)
    self.encrypted_password = ["sha1", Base64.encode64(pbkdf2)].join(':')
    self.save!
  end

  def password_valid?(password)
    params = self.encrypted_password.split(':')
    return false if params.length != 2

    pbkdf2 = Base64.decode64(params[1])
    testHash = OpenSSL::PKCS5::pbkdf2_hmac_sha1(password, self.salt, 1000, pbkdf2.length)

    return pbkdf2 == testHash
  end

  def is_boombox_user?
    bike_user_id.nil?
  end

  private
  def set_default_playlist
    self.boom_playlists.create(name: '我喜欢的音乐', is_default: 1, mode: 0)
  end
end
