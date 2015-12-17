class MessageTask < ActiveRecord::Base
  default_scope {order('created_at')}
  belongs_to :boom_message

  delegate :title, :content, :subject_type, :subject_id, :start_time, to: :boom_message
  after_commit :async_push, on: :create

  scope :ios, -> {where(platform: 'ios')}
  scope :android, -> {where(platform: 'android')}

  def targets
    boom_message.get_target_users.join("\n")
  end

  def status_cn
    case status
    when 0
      "排队中"
    when 1
      "发送中"
    when 2
      "发送完成"
    when 3
      "发送失败"
    when 6
      "筛选结果为空"
    else
      "#{status} - 其他"
    end
  end

  def async_push
    UmengPushWorker.perform_async(self.id, "upload")
    UmengPushWorker.perform_in(8.minutes, self.id, "check")
  end
end
