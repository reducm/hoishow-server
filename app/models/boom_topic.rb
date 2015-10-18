class BoomTopic < ActiveRecord::Base
  belongs_to :collaborator

  has_many :boom_user_likes, -> { where subject_type: BoomUserLike::SUBJECT_TOPIC }, foreign_key: 'subject_id'
  has_many :likers, through: :boom_user_likes, source: :user

  has_many :boom_comments, dependent: :destroy

  validates :subject_type, presence: true
  validates :content, presence: true
  validates :subject_id, presence: true

  def subject
     begin
      Object::const_get(subject_type).where(id: subject_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, boom_topic_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
     end
  end

  def creator_avatar
    collaborator.cover_url
  end

  def likes_count
    likers.count
  end

  def comments_count
    boom_comments.count
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
