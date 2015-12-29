class BoomTrack < ActiveRecord::Base
  include Searchable

  CREATOR_ADMIN = 'BoomAdmin'
  CREATOR_COLLABORATOR = 'Collaborator'

  has_many :playlist_track_relations, dependent: :destroy
  has_many :playlists, through: :playlist_track_relations, source: :boom_playlist

  has_many :activity_track_relations
  #实际数据为boom_activity中的show
  has_many :activities, ->{ where mode: 0 }, through: :activity_track_relations, source: :boom_activity

  has_many :tag_subject_relations, as: :subject, dependent: :destroy
  has_many :boom_tags, through: :tag_subject_relations, as: :subject,
            after_add: [:track_add_radio, lambda { |a,c| a.__elasticsearch__.index_document } ],
            after_remove: [:track_remove_radio, lambda { |a,c| a.__elasticsearch__.index_document } ]

  validates :name, presence: true
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  mount_uploader :file, AudioUploader
  mount_uploader :cover, BoomImageUploader

  after_create :set_removed_and_is_top, :convert_audio
  after_commit :convert_audio_if_changed, on: :update

  scope :valid, -> {where(removed: false).order('is_top desc, created_at desc')}

  paginates_per 10

  mapping dynamic: 'false' do
    indexes :name, analyzer: 'snowball'
    indexes :artists, analyzer: 'snowball'
    indexes :boom_tags, type: 'nested' do
      indexes :name, analyzer: 'snowball'
    end
  end

  def as_indexed_json(options={})
    as_json(
      only: [:name, :artists],
      include: { boom_tags: {only: :name} }
    )
  end

  def self.recommend(user=nil)
    if user
      Rails.cache.fetch("user:#{user.id}:tracks:recommend", expires_in: 1.day) do
        tracks = user.recommend_tracks
        if tracks.size >= 20
          tracks
        else
          order('is_top, RAND()').limit(20).to_a
        end
      end
    else
      Rails.cache.fetch("tracks:recommend", expires_in: 1.day) do
        order('is_top, RAND()').limit(20).to_a
      end
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
      "推荐中"
    else
      "没有推荐"
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
    else
      "0:00"
    end
  end

  def tag_for_track(tag)
    tag_subject_relations.where(boom_tag_id: tag.id).first_or_create!
  end

  def track_add_radio(tag)
    radio = BoomPlaylist.where(name: tag.name).first
    radio.playlist_track_relations.where(boom_track_id: self.id).first_or_create! if radio
  end

  def track_remove_radio(tag)
    radio = BoomPlaylist.where(name: tag.name).first
    if radio
      relation = radio.playlist_track_relations.where(boom_track_id: self.id).first
      relation.destroy! if relation
    end
  end

  def is_liked?(user)
    id.in? (user.boom_playlists.default.tracks.ids) rescue false
  end

  # 以mb为单位
  def file_size
    if file.present?
      (file.size / 1024 / 1024.to_f).round(2)
    else
      0
    end
  end

  def create_or_update_tag_relations(tag_ids = [])
    tag_ids = tag_ids.split(",")
    BoomTag.where(id: tag_ids).each do |tag|
      tag.tag_subject_relations.where(subject_id: self.id, subject_type: 'BoomTrack').first_or_create!
    end
    self.tag_subject_relations.where.not(boom_tag_id: tag_ids).delete_all
  end

  def create_tag_using_artists(artists_string = [])
    artists = artists_string.split(",")
    a_tags = []
    artists.each do |artist|
      name = artist.gsub(/\s/, "").downcase
      a_tags << BoomTag.where(name: name, lower_string: name).first_or_create!
    end
    a_tags.each do |tag|
      tag.tag_subject_relations.where(subject_id: self.id, subject_type: 'BoomTrack').first_or_create!
    end
  end

  def current_cover_url
    cover_url || fetch_cover_url
  end

  def current_file_url
    file_url || fetch_file_url
  end

  def creator_name
    case creator_type
    when CREATOR_COLLABORATOR
      creator.display_name
    when CREATOR_ADMIN
      creator.default_name
    end rescue nil
  end

  private
  def set_removed_and_is_top
    unless is_top
      self.update(removed: 0, is_top: 0)
    else
      self.update(removed: 0)
    end
  end

  def convert_audio
    ConvertAudioWorker.perform_async(file.path) if file_url
  end

  def convert_audio_if_changed
    convert_audio if previous_changes['file']
  end
end
