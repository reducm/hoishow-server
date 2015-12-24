class BoomTopicAttachment < ActiveRecord::Base
  default_scope {order('created_at ASC')}
  belongs_to :boom_topic

  mount_uploader :image, BoomImageUploader

  def photo_version
    if self.image_url.present?
      if Rails.env.development?
        self.image_url
      else
        self.image_url + "!photo"
      end
    else
      ''
    end
  end
end
