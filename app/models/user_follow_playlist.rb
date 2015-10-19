class UserFollowPlaylist < ActiveRecord::Base
  belongs_to :user
  belongs_to :boom_playlist
end
