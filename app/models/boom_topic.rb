class BoomTopic < ActiveRecord::Base
  belongs_to :collaborator

  has_many :boom_user_likes, -> { where subject_type: BoomUserLike::SUBJECT_TOPIC }, foreign_key: 'subject_id', dependent: :destroy
  has_many :likers, through: :boom_user_likes, source: :user

  has_many :boom_comments, dependent: :destroy

  validates :subject_type, presence: true
  validates :content, presence: true
  validates :subject_id, presence: true

  before_create :set_is_top

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

  def last_reply_time
    if boom_comments.any?
      boom_comments.order('updated_at desc').last.updated_at
    else
      self.created_at
    end
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

  private
  def set_is_top
    self.is_top = false
    # 这里的最后返回值刚好是false，会导致save失败，before callback最后要返回true
    # http://makandracards.com/makandra/791-dealing-with-activerecord-recordnotsaved
    true
  end
end
