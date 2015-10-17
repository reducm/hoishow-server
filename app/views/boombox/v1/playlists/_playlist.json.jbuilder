user ||= nil

json.(playlist, :id, :name)
json.is_followed playlist.is_followed(user.try(:id))
json.tracks do
  json.array! playlist.tracks do |track|
    json.(track, :id, :name, :artists, :duration)
    json.file track.file_url || ''
  end
end
