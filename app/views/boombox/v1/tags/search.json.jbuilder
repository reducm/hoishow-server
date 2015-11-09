json.collaborators do
  json.array! @collaborators.first(4) do |colla|
    json.(colla, :id, :name, :followed_count)
    json.cover colla.cover_url || ''
  end
end

json.activities do
  json.array! @activities do |activity|
    json.(activity, :id, :name, :showtime, :mode)
    json.location_name activity.location_name
    json.poster activity.cover_url || ''
  end
end

json.tracks do
  json.array! @tracks.first(3) do |track|
    json.(track, :id, :name, :artists, :duration)
    json.file track.file_url || ''
  end
end

json.playlists do
  json.array! @playlists do |playlist|
    json.(playlist, :id, :name)
    json.tracks do
      json.array! playlist.tracks do |track|
        json.(track, :id, :name, :artists, :duration)
        json.file track.file_url || ''
      end
    end
  end
end
