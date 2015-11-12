class BoomComment < ActiveRecord::Base
  include BoomCommentSearchable 

  CREATOR_COLLABORATOR = 'Collaborator'
  CREATOR_USER = 'User'

  has_many :boom_user_likes, -> { where subject_type: BoomUserLike::SUBJECT_COMMENT }, foreign_key: 'subject_id'
  has_many :likers, through: :boom_user_likes, source: :user

  belongs_to :boom_topic
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  def as_indexed_json(options={})
    as_json(
      only: :content
    )
  end

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("creator wrong, boom_comment_id: #{id}, creator_type: #{creator_type}, creator_id: #{creator_id}")
      nil
    end
  end

  def creator_avatar
    case creator_type
    when CREATOR_COLLABORATOR
      creator.cover_url
    when CREATOR_USER
      creator.avatar_url
    end
    rescue nil
  end

  def likes_count
    likers.count
  end

  def created_by
    creator.name rescue nil
  end

  def is_liked(user_id)
    user_id.in?(boom_user_likes.pluck(:user_id))
  end

  def content=(value)
    write_attribute(:content, Base64.encode64(value))
  end

  def content
    Base64.decode64(read_attribute(:content)).force_encoding("utf-8")
  end
end

BoomComment.import(force: true)
