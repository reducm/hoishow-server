class BoomComment < ActiveRecord::Base
  default_scope {order('created_at DESC')}
  include Searchable

  CREATOR_COLLABORATOR = 'Collaborator'
  CREATOR_USER = 'User'
  CREATOR_ADMIN = 'BoomAdmin'

  has_many :boom_user_likes, as: :subject, dependent: :destroy
  #把likers改成users则不用加source: :user
  has_many :likers, through: :boom_user_likes, as: :subject, source: :user

  belongs_to :boom_topic
  belongs_to :user

  validates :creator_id, presence: true
  validates :creator_type, presence: true

  paginates_per 10

  def send_reply_push
    BoomMessage.create(subject_type: BoomMessage::SUBJECT_COMMENT, subject_id: self.id, targets: 'specific', send_type: 'comment_replay', title: '您有新的回复', content: self.content)
  end

  def parent_target_id
    BoomComment.find_by_id(parent_id).creator_id rescue nil
  end

  def as_indexed_json(options={})
    as_json(
      only: :content
    )
  end

  def creator_name
    case creator_type
    when CREATOR_COLLABORATOR
      creator.display_name
    when CREATOR_ADMIN
      creator.default_name
    when CREATOR_USER
      creator.show_name
    end rescue nil
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
    creator.avatar_url rescue nil
  end

  def likes_count
    likers.count
  end

  def created_by
    creator_name
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

  def reply_content
    if parent_id
      parent = BoomComment.find_by_id(parent_id)
      "回复@#{parent.try(:creator_name)} : #{content}"
    else
      content
    end
  end
end
