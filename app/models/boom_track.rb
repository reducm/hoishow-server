require 'elasticsearch/model'

class BoomTrack < ActiveRecord::Base
  include Elasticsearch::Model
  include Elasticsearch::Model::Callbacks

  CREATOR_ADMIN = 'BoomAdmin'
  CREATOR_COLLABORATOR = 'Collaborator'

  has_many :playlist_track_relations, dependent: :destroy
  has_many :playlists, through: :playlist_track_relations, source: :boom_playlist

  has_many :activity_track_relations
  has_many :activities, through: :activity_track_relations, source: :boom_activity

  scope :recommend, -> { order('is_top, RAND()').limit(20) }

  has_many :tag_subject_relations, as: :subject
  has_many :boom_tags, through: :tag_subject_relations, as: :subject

  validates :name, presence: true
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  mount_uploader :file, AudioUploader
  mount_uploader :cover, ImageUploader

  after_create :set_removed_and_is_top
  scope :valid, -> {where(removed: false).order('is_top, created_at desc')}

  paginates_per 10

  def as_indexed_json(options={})
    as_json(
      only: [:name, :artists]
    )
  end

  def self.recommend(user=nil)
    Rails.cache.fetch("tracks:recommend", expires_in: 1.day) do
      user ? user.recommend_tracks : BoomTrack.order('is_top, RAND()').limit(20).to_a
    end
  end

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("creator wrong, boom_track_id: #{id}, creator_type: #{creator_type}, creator_id: #{creator_id}")
      nil
    end
  end

  def is_top_cn
    if is_top
      "取消推荐"
    else
      "推荐"
    end
  end

  def duration_to_time
    if duration
      m, s = duration.to_i.divmod(60)
      if m < 10
        m = "0" + m.to_s
      end
      if s < 10
        s = "0" + s.to_s
      end
      "#{m}:#{s}"
    end
  end

  def tag_for_track(tag)
    tag_subject_relations.where(boom_tag_id: tag.id).first_or_create!
  end

  private
  def set_removed_and_is_top
    unless is_top
      self.update(removed: 0, is_top: 0)
    else
      self.update(removed: 0)
    end
  end
end
