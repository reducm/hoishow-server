class BoomAlbum < ActiveRecord::Base
  default_scope {order('is_cover DESC, created_at DESC')}
  belongs_to :collaborator

  mount_uploader :image, BoomImageUploader

  paginates_per 10
end
