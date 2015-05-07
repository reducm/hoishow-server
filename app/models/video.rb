class Video < ActiveRecord::Base
  belongs_to :star
  belongs_to :concert

  validates :source, presence: true
  validates :star_id, presence: true

  scope :is_main, -> { where(is_main: true)  }

  mount_uploader :source, VideoUploader
  mount_uploader :snapshot, ImageUploader
end
