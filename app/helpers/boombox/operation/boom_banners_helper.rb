module Boombox::Operation::BoomBannersHelper
  def subject_type_option(subject_type)
    case subject_type
    when "BoomPlaylist"
      "Playlist"
    when "BoomActivity"
      "Activity"
    end
  end
end
