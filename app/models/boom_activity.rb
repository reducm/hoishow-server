class BoomActivity < ActiveRecord::Base
  belongs_to :boom_location
  belongs_to :boom_admin

  has_many :collaborator_activity_relations
  has_many :collaborators, through: :collaborator_activity_relations, source: :collaborator

  has_many :activity_track_relations
  has_many :tracks, through: :activity_track_relations, source: :boom_track

  has_many :tag_subject_relations, -> { where subject_type: TagSubjectRelation::SUBJECT_ACTIVITY }, foreign_key: 'subject_id'
  has_many :tags, through: :tag_subject_relations, source: :boom_tag

  enum mode: {
    show: 0,
    activity: 1
  }

  scope :is_display, ->{ where is_display: true }

  mount_uploader :cover, ImageUploader

  paginates_per 10

  def location_name
    boom_location.name if boom_location
  end
end
