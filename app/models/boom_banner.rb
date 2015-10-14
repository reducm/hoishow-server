class BoomBanner < ActiveRecord::Base
  validates :subject_id, presence: true
  validates :subject_type, presence: true
  validates :position, uniqueness: true

  def subject
     begin
      Object::const_get(subject_type).where(id: subject_id).first
    rescue => e
      #ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      ExceptionNotifier.notify_exception(e).deliver_now
      Rails.logger.fatal("subject wrong, banner_id: #{ id }, subject_type: #{subject_type}, subject_id: #{subject_id}")
      nil
     end
  end
end
