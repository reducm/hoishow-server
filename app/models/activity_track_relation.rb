class ActivityTrackRelation < ActiveRecord::Base
  belongs_to :boom_activity
  belongs_to :boom_track
end
