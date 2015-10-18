json.array! @playlists do |playlist|
  json.(platlist, :id, :name)
  json.tracks do
    json.array! playlist.tracks do |track|
      json.(track, :name, :artists, :duration)
      json.file track.file_url
    end
  end
end
