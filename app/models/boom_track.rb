class BoomTrack < ActiveRecord::Base
  CREATOR_ADMIN = 'BoomAdmin'
  CREATOR_COLLABORATOR = 'Collaborator'

  has_many :playlist_track_relations
  has_many :playlists, through: :playlist_track_relations, source: :boom_playlist

  has_many :activity_track_relations
  has_many :activities, through: :activity_track_relations, source: :boom_activity

  has_many :tag_subject_relations, -> { where subject_type: TagSubjectRelation::SUBJECT_TRACK }, foreign_key: 'subject_id'
  has_many :tags, through: :tag_subject_relations, source: :boom_tag

  scope :recommend, -> { order('is_top, RAND()').limit(20) }
  #取出合集得时候不要忘记过滤
  scope :valid_tracks, -> {where removed: false}

  validates :name, presence: true
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  mount_uploader :file, AudioUploader
  mount_uploader :cover, ImageUploader

  after_create :set_removed_and_is_top

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
