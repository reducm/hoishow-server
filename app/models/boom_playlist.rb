class BoomPlaylist < ActiveRecord::Base
  CREATOR_ADMIN = 'BoomAdmin'
  CREATOR_COLLABORATOR = 'Collaborator'
  CREATOR_USER = 'User'

  has_many :user_follow_playlists
  has_many :followers, through: :user_follow_playlists, source: :user
  has_many :boom_tracks

  validates :name, presence: true
  validates :creator_id, presence: true
  validates :creator_type, presence: true

  enum mode: {
    playlist: 0,
    radio: 1
  }

  scope :open, -> { where('creator_type != ?', CREATOR_USER)}

  paginates_per 10

  def creator
    begin
      Object::const_get(creator_type).where(id: creator_id).first
    rescue => e
      ExceptionNotifier::Notifier.background_exception_notification(e).deliver_now
      Rails.logger.fatal("creator wrong, boom_comment_id: #{id}, creator_type: #{creator_type}, creator_id: #{creator_id}")
      nil
    end
  end

  def is_followed(user_id)
    user_id.in?(user_follow_playlists.pluck(:user_id))
  end
end
