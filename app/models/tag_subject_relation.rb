class TagSubjectRelation < ActiveRecord::Base
  SUBJECT_COLLABORATOR = 'Collaborator'
  SUBJECT_ACTIVITY = 'BoomActivity'
  SUBJECT_TRACK = 'BoomTrack'
  SUBJECT_PLAYLIST = 'BoomPlaylist'

  belongs_to :boom_tag
  belongs_to :subject, polymorphic: true

  validates :subject_type, presence: true
  validates :subject_id, presence: true
end
