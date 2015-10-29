class Collaborator < ActiveRecord::Base
  has_many :user_follow_collaborators
  has_many :followers, through: :user_follow_collaborators, source: :user

  has_many :collaborator_activity_relations
  has_many :activities, through: :collaborator_activity_relations, source: :boom_activity

  has_many :boom_albums
  has_many :boom_topics
  has_many :boom_playlists, -> { where creator_type: BoomPlaylist::CREATOR_COLLABORATOR }, foreign_key: 'creator_id'
  has_many :boom_tracks, -> { where creator_type: BoomTrack::CREATOR_COLLABORATOR }, foreign_key: 'creator_id'
  has_many :boom_activities

  has_many :tag_subject_relations, -> { where subject_type: TagSubjectRelation::SUBJECT_COLLABORATOR }, foreign_key: 'subject_id'
  has_many :tags, through: :tag_subject_relations, source: :boom_tag

  mount_uploader :cover, ImageUploader
  after_create :set_removed_and_is_top
  scope :verified, -> { where(verified: true, removed: false).order('is_top') }

  paginates_per 10

  def is_followed(user_id)
    user_id.in?(user_follow_collaborators.pluck(:user_id))
  end

  def followed_count
    followers.count
  end

  private
  def set_removed_and_is_top
    self.update(removed: 0, is_top: 0)
  end
end
