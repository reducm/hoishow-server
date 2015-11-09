require 'elasticsearch/model'

class BoomActivity < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  belongs_to :boom_location
  belongs_to :boom_admin

  has_many :collaborator_activity_relations
  has_many :collaborators, through: :collaborator_activity_relations, source: :collaborator

  has_many :activity_track_relations
  has_many :tracks, through: :activity_track_relations, source: :boom_track

  has_many :tag_subject_relations, as: :subject
  has_many :boom_tags, through: :tag_subject_relations, as: :subject

  enum mode: {
    show: 0,
    activity: 1
  }
  after_create :set_removed_and_is_top

  scope :is_display, ->{ where(is_display: true, removed: false).order('is_top')}

  mount_uploader :cover, ImageUploader

  paginates_per 10

  def location_name
    boom_location.name if boom_location
  end

  private
  def set_removed_and_is_top
    self.update(removed: 0, is_top: 0)
  end
end
