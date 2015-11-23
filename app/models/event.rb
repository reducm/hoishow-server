class Event < ActiveRecord::Base
  default_scope {order('show_time')}
  has_many :areas, dependent: :destroy
  belongs_to :show

  mount_uploader :stadium_map, ImageUploader
  mount_uploader :coordinate_map, ImageUploader
end
