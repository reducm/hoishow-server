class Collaborator < ActiveRecord::Base
  has_many :boom_albums
  has_many :user_follow_collaborators
  has_many :followers, through: :user_follow_collaborators, source: :user
  mount_uploader :cover, ImageUploader

  scope :verified, -> { where(verified: true) }

  paginates_per 10

  def is_followed(user_id)
    user_id.in?(user_follow_collaborators.pluck(:user_id))
  end

  def followed_count
    followers.count
  end
end
