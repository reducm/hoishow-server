module Boombox::Operation::BoomBannersHelper
  def subject_type_option(subject_type)
    case subject_type
    when "Collaborator"
      [["艺人", "Collaborator"], ["活动", "Activity"], ["playlist", "Playlist"]]
    when "BoomPlaylist"
      [["playlist", "Playlist"], ["艺人", "Collaborator"], ["活动", "Activity"]]
    when "BoomActivity"
      [["活动", "Activity"], ["艺人", "Collaborator"], ["playlist", "Playlist"]]
    end
  end
end
