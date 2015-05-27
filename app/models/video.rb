class Video < ActiveRecord::Base
  belongs_to :star
  belongs_to :concert

  validates :source, presence: true
  validates :star_id, presence: true
  validates :star, presence: true
  validate :video_size_validation, :if => "source?"

  scope :is_main, -> { where(is_main: true)  }

  mount_uploader :source, VideoUploader
  mount_uploader :snapshot, ImageUploader

  def video_size_validation 
    errors[:source] << " 单个文件最大30MB" if source.size > 30.megabytes
  end
end
