user ||= nil

json.(track, :id, :name, :artists)
json.duration (track.duration.to_f * 1000).to_i
json.cover track.current_cover_url || ''
json.file track.file_url || ''
json.is_liked track.is_liked?(user)
