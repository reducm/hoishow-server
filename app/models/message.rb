include UmengMessage
class Message < ActiveRecord::Base
  has_many :user_message_relation
  has_many :target_users, through: :user_message_relation, source: :user

  validates :creator_type, presence: true
  validates :subject_type, presence: true
  validates :content, presence: true
  validates :title, presence: true
  validates :notification_text, presence: true
  validates :send_type, presence: true

  paginates_per 20

  enum send_type: {
    new_show: 0, #有新show时的通知
    all_users_buy: 1, #开放所有用户买票的通知
    new_concert: 2, #有新concert时的通知
    comment_reply: 3, #回覆评论的通知
    topic_reply: 4, #回覆主题的通知
    manual: 5 #手动推送通知
  }

  def send_type_cn
    case send_type
    when 'new_show'
      '发布新show时'
    when 'all_users_buy'
      '开放所有用户购买'
    when 'new_concert'
      '发布新concert时'
    when 'comment_reply'
      '评论有新的回覆时'
    when 'topic_reply'
      '主题有新的回覆时'
    when 'manual'
      '手动推送'
    end
  end

  def subject
     begin
      Object::const_get(subject_type).where(id: subject_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("subject wrong, topic_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
     end
  end

  def send_umeng_message(content, message)
    android_send_message(content, message.notification_text, message.title, message.content)
  end

  def creator_type_cn
    case creator_type
    when 'All'
      '全部用户'
    when 'Concert'
      '关注concert的用户'
    when 'Show'
      '关注show的用户'
    when 'Star'
      '关注star的用户'
    end
  end

end
