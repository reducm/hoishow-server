#encoding: UTF-8
class Video < ActiveRecord::Base
  belongs_to :star
  belongs_to :concert

  validates :source, presence: true

  scope :is_main, -> { where(is_main: true)  }
  scope :star_id_not_set, -> { where("star_token IS NOT NULL AND star_id IS NULL") }
  # 在哪里清理掉比较好？
  #scope :star_id_not_set_after_one_day, -> { where("star_token IS NOT NULL AND star_id IS NULL AND created_at < ?", Time.now - 1.day) }

  mount_uploader :source, VideoUploader
  mount_uploader :snapshot, ImageUploader
end
