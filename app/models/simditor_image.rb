class SimditorImage < ActiveRecord::Base
  mount_uploader :image, ImageUploader
  validates_presence_of :image
end
