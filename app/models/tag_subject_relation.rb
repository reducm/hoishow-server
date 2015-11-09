class TagSubjectRelation < ActiveRecord::Base
  SUBJECT_COLLABORATOR = 'Collaborator'
  SUBJECT_ACTIVITY = 'BoomActivity'
  SUBJECT_TRACK = 'BoomTrack'
  SUBJECT_PLAYLIST = 'BoomPlaylist'

  belongs_to :boom_tag
  belongs_to :subject, polymorphic: true

  validates :subject_type, presence: true
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
