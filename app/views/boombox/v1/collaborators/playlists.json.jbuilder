@user ||= nil

json.array! @playlists do |pl|
  json.(pl, :id, :name)
  json.is_followed pl.is_followed(@user.try(:id))
  json.tracks do
    json.array! pl.boom_tracks do |track|
      json.(track, :id, :name, :artists, :duration)
      json.file track.file_url || ''
    end
  end
end
