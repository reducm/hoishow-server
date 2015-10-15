class BoomTopic < ActiveRecord::Base
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
end
