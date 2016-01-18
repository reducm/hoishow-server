class PlaylistTrackRelation < ActiveRecord::Base
  belongs_to :boom_playlist, touch: true
  belongs_to :boom_track
end
