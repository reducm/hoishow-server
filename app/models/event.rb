class Event < ActiveRecord::Base
  has_many :areas, dependent: :destroy
  belongs_to :show

  mount_uploader :stadium_map, ImageUploader
  mount_uploader :coordinate_map, ImageUploader
end
