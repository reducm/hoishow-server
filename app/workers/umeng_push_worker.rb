# coding: utf-8

require "umeng_msg"

class UmengPushWorker
  include Sidekiq::Worker
  sidekiq_options retry: 1, queue: 'umeng_msg', backtrace: true

  def perform(push_task_id, flag)
    case flag
    when "push"
      do_push(push_task_id)
    when "check"
      do_check(push_task_id)
    when "upload"
      do_upload_and_push(push_task_id)
    end
  end

  def do_push(push_task_id)
    task = MessageTask.find(push_task_id)
    message = task.boom_message

    push_params = {
      title: task.title,
      content: task.content,
      subject_type: task.subject_type,
      subject_id: task.subject_id,
      file_id: task.file_id
    }

    if message.message_tasks.all? { |task| task.status.nil?  }
      push_params = {
        start_time: (task.start_time.present? ? task.start_time.strftime("%Y-%m-%d %H:%M:%S") : ""),
      }.merge(push_params)
    end

    if message.subject_type == 'BoomActivity' && message.subject.activity?
      push_params = {
        description: "/api/boombox/v1/activities/#{message.subject_id}/description",
        activity_name: message.subject_name
      }.merge(push_params)
    end

    if push_result = UmengMsg::Service.push(task.platform, push_params)
      task.update(task_id: push_result["task_id"])
      if message.status.to_i < 3
        message.update(status: 3)
      end
    else
      # 发送失败
      task.update(status: 3)
      message.update(status: 4)
    end

  end

  def do_check(push_task_id)
    task = MessageTask.find(push_task_id)
    if check_result = UmengMsg::Service.check(task.platform, task.task_id)
      task.update(
        status: check_result["status"],
        total_count: check_result["sent_count"]
      )
    end
  end

  def do_upload_and_push(push_task_id)
    task = MessageTask.find(push_task_id)
    if upload_result = UmengMsg::Service.upload(task.platform, task.targets)
      task.update(file_id: upload_result['file_id'])
      do_push(push_task_id)
    end
  end
end
