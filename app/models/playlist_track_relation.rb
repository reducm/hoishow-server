class PlaylistTrackRelation < ActiveRecord::Base
  belongs_to :boom_playlist
  belongs_to :boom_track
end
