class BoomActivity < ActiveRecord::Base
  belongs_to :boom_location
  belongs_to :boom_admin

  has_many :collaborator_activity_relations
  has_many :collaborators, through: :collaborator_activity_relations, source: :collaborator

  enum mode: {
    show: 0,
    activity: 1
  }

  mount_uploader :cover, ImageUploader

  def location_name
    boom_location.name if boom_location
  end
end
