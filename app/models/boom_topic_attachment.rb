class BoomTopicAttachment < ActiveRecord::Base
  default_scope {order('created_at ASC')}
  belongs_to :boom_topic

  mount_uploader :image, BoomImageUploader
end
