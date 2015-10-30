class BoomTrack < ActiveRecord::Base
  CREATOR_ADMIN = 'BoomAdmin'
  CREATOR_COLLABORATOR = 'Collaborator'

  has_many :playlist_track_relations
  has_many :playlists, through: :playlist_track_relations, source: :boom_playlist

  has_many :activity_track_relations
  has_many :activities, through: :activity_track_relations, source: :boom_activity

  has_many :tag_subject_relations, -> { where subject_type: TagSubjectRelation::SUBJECT_TRACK }, foreign_key: 'subject_id'
  has_many :tags, through: :tag_subject_relations, source: :boom_tag

  validates :name, presence: true
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  mount_uploader :file, AudioUploader
  mount_uploader :cover, ImageUploader

  after_create :set_removed_and_is_top

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

  private
  def set_removed_and_is_top
    self.update(removed: 0, is_top: 0)
  end
end
