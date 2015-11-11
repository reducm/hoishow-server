user ||= nil
need_tracks ||= false

json.(playlist, :id, :name)
json.cover playlist.cover_url || ''
json.is_followed playlist.is_followed(user.try(:id))

if need_tracks
  json.tracks do
    json.array! tracks, partial: 'boombox/v1/tracks/track', as: :track
  end
end
