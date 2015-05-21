include UmengMessage
class Message < ActiveRecord::Base
  has_many :user_message_relations
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

  def send_umeng_message(users_array, message, get_task_id_fail: "task_id获取失败，消息创建成功，推送发送失败", none_follower: "关注用户数为0，消息创建失败")
    if ( users_array.count > 0 ) &&  message.save!
      content = message.create_relation_with_users(users_array)
      task_id = message.android_send_message(content, message.notification_text, message.title, message.content)
      if task_id
        message.update!(task_id: task_id)
        s = "success"
      else
        get_task_id_fail 
      end
    else
      none_follower
    end
  end

  def create_relation_with_users(users_array)
    content = ""
    users_array.each do |user|
      user_message_relations.where(user: user).first_or_create!
      content = content + user.mobile + "\n"
    end
    content
  end

end
