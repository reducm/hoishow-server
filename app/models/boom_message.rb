class BoomMessage < ActiveRecord::Base
  include ModelAttrI18n
  default_scope {order('created_at DESC')}
  SUBJECT_COLLABORATOR = 'Collaborator'
  SUBJECT_ACTIVITY = 'BoomActivity'
  SUBJECT_PLAYLIST = 'BoomPlaylist'

  belongs_to :boom_admin
  has_many :message_tasks

  has_many :boom_user_message_relations
  has_many :users, through: :boom_user_message_relations, source: :user

  validates :subject_type, presence: true
  validates :subject_id, presence: true
  validates :send_type, presence: true
  validates :title, presence: true
  validates :start_time, presence: true
  validates :content, length: { maximum: 150 }

  enum send_type: {
    manual: 0 #手动推送
  }

  enum targets: {
    all_users: 0, #全部用户
    followers: 1 #关注用户
  }

  paginates_per 10

  after_create :set_user_message_relations, :set_message_tasks

  def subject
    begin
      Object::const_get(subject_type).where(id: subject_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, message_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
    end
  end

  def subject_name
    subject.name rescue nil
  end

  def subject_type_cn
    case
    when subject_type == SUBJECT_COLLABORATOR
      '艺人'
    when subject_type == SUBJECT_PLAYLIST
      'playlist'
    when subject_type == SUBJECT_ACTIVITY && subject.show?
      '演出'
    when subject_type == SUBJECT_ACTIVITY && subject.activity?
      '活动'
    else
      '其他'
    end
  end

  def targets_cn
    tran("targets")
  end

  def total_count
    message_tasks.sum(:total_count)
  end

  def push_time
    last_task = message_tasks.last
    if last_task && start_time < last_task.created_at
      last_task.created_at
    else
      start_time
    end
  end

  def pushed?
    start_time < Time.now
  end

  def set_message_tasks
    %w(ios android).each do |platform|
      message_tasks.create(platform: platform)
    end
  end

  def get_target_users
    case targets
    when 'all_users'
      User.ids
    when 'followers'
      subject.followers.ids
    else
      nil
    end
  end

  private

  def set_user_message_relations
    targets = get_target_users
    targets.each do |user_id|
      boom_user_message_relations.create(user_id: user_id)
    end
  end
end
