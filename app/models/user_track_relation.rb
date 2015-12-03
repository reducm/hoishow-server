class UserTrackRelation < ActiveRecord::Base
  belongs_to :user
  belongs_to :boom_track
end
