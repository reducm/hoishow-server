class BoomAlbum < ActiveRecord::Base
  belongs_to :collaborator

  mount_uploader :image, BoomImageUploader

  paginates_per 10
end
