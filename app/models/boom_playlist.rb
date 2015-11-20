class BoomPlaylist < ActiveRecord::Base
  include Searchable

  CREATOR_ADMIN = 'BoomAdmin'
  CREATOR_COLLABORATOR = 'Collaborator'
  CREATOR_USER = 'User'

  has_many :user_follow_playlists
  has_many :followers, through: :user_follow_playlists, source: :user

  has_many :playlist_track_relations, dependent: :destroy
  has_many :tracks, through: :playlist_track_relations, source: :boom_track

  has_many :tag_subject_relations, as: :subject
  has_many :boom_tags, through: :tag_subject_relations, as: :subject,
            after_add: [ lambda { |a,c| a.__elasticsearch__.index_document } ],
            after_remove: [ lambda { |a,c| a.__elasticsearch__.index_document } ]

  validates :name, presence: true
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  enum mode: {
    playlist: 0,
    radio: 1
  }

  after_create :set_removed_and_is_top

  mount_uploader :cover, ImageUploader

  #取出合集得时候不要忘记过滤
  scope :valid_playlists, -> { where("removed = false and mode = 0") }
  scope :valid_radios, -> { where("removed = false and mode = 1") }
  #for api
  scope :open, -> { where('creator_type != ? and removed = false', CREATOR_USER).order('is_top, RAND()')}

  paginates_per 10

  mapping do
    indexes :name, analyzer: 'snowball'
    indexes :boom_tags, type: 'nested' do
      indexes :name, analyzer: 'snowball'
    end
  end

  def as_indexed_json(options={})
    as_json(
      only: :name,
      include: { boom_tags: {only: :name} }
    )
  end

  def self.recommend(user=nil)
    if user
      Rails.cache.fetch("user:#{user.id}:playlists:recommend", expires_in: 1.day) do
        if user.recommend_playlists.any?
          user.recommend_playlists
        else
          playlist.open.to_a
        end
      end
    else
      Rails.cache.fetch("playlists:recommend", expires_in: 1.day) do
        playlist.open.to_a
      end
    end
  end

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("creator wrong, boom_playlist_id: #{id}, creator_type: #{creator_type}, creator_id: #{creator_id}")
      nil
    end
  end

  def is_followed(user_id)
    user_id.in?(user_follow_playlists.pluck(:user_id))
  end

  def is_top_cn
    if is_top
      "推荐中"
    else
      "没有推荐"
    end
  end

  def tag_for_playlist(tag)
    tag_subject_relations.where(boom_tag_id: tag.id).first_or_create!
  end

  def tracks_count
    tracks.count
  end

  private
  def set_removed_and_is_top
    if is_top
      self.update(removed: 0)
    else
      self.update(removed: 0, is_top: 0)
    end
  end
end
