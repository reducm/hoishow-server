#encoding: UTF-8
class Topic < ActiveRecord::Base
  default_scope {order('topics.is_top DESC, topics.created_at DESC')}

  SUBJECT_CONCERT = 'Concert'
  SUBJECT_STAR = 'Star'
  SUBJECT_SHOW = 'Show'

  CREATOR_USER = 'User'
  CREATOR_STAR = 'Star'
  CREATOR_ADMIN = 'Admin'

  belongs_to :city
  validates :creator_id, presence: true
  validates :creator_type, presence: true
  validates :subject_type, presence: true
  validates :content, presence: true
  validates :subject_id, presence: true
  validates :content, length: { maximum: 150 }

  has_many :comments
  has_many :user_like_topics
  has_many :likers, through: :user_like_topics, source: :user

  paginates_per 10

  def subject
     begin
      Object::const_get(subject_type).where(id: subject_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, topic_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
     end
  end

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("creator wrong, topic_id: #{ id }, creator_type: #{creator_type}, creator_id: #{creator_id}")
      nil
    end
  end

  def creator_name
    if creator.is_a?(User)
      creator.show_name
    elsif creator.is_a?(Admin)
      creator.default_name
    elsif creator.is_a?(Star)
      creator.name
    end
  end

  def is_like(user)
    ids = user_like_topics.pluck(:user_id)
    user.id.in?(ids) rescue false
  end

  def like_count
    user_like_topics.count
  end

  def reply_count
    comments.count
  end

  def last_reply_time
    if comments.any?
      comments.order('updated_at desc').last.updated_at
    else
      self.created_at
    end
  end
end
