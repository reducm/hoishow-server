class BoomAlbum < ActiveRecord::Base
  belongs_to :collaborator

  mount_uploader :image, ImageUploader
end
