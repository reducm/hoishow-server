@user ||= nil

json.collaborators do
  json.array! @records[:collaborators].first(4) do |colla|
    json.(colla, :id, :name, :followed_count)
    json.cover colla.cover_url || ''
  end
end

json.activities do
  json.array! @records[:activities].first(3) do |activity|
    json.(activity, :id, :name, :showtime, :mode)
    json.location_name activity.location_name
    json.poster activity.cover_url || ''
  end
end

json.tracks do
  json.array! @records[:tracks].first(3), partial: 'boombox/v1/tracks/track', as: :track
end

json.playlists do
  json.array! @records[:playlists].first(3), partial: 'boombox/v1/playlists/playlist', as: :playlist, user: @user
end
