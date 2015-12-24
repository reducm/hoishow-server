@user ||= nil

json.collaborators do
  json.array! @records[:collaborators].first(4) do |colla|
    json.(colla, :id, :followed_count)
    json.name colla.display_name
    json.cover colla.cover_url || ''
  end
end
json.collaborator_count @records[:collaborators].count

json.activities do
  json.array! @records[:activities].first(3) do |activity|
    json.(activity, :id, :name, :showtime, :mode)
    json.location_name activity.location_name
    json.poster activity.cover_url || ''
    json.description description_boombox_v1_activity_url(activity)
  end
end
json.activity_count @records[:activities].count

json.tracks do
  json.array! @records[:tracks].first(3), partial: 'boombox/v1/tracks/track', as: :track, user: @user
end
json.track_count @records[:tracks].count

json.playlists do
  json.array! @records[:playlists].first(3), partial: 'boombox/v1/playlists/playlist', as: :playlist, user: @user, need_track_ids: true
end
json.playlist_count @records[:playlists].count
