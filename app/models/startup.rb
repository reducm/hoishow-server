class Startup < ActiveRecord::Base
  mount_uploader :pic, ImageUploader
end
