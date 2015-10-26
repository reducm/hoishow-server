user ||= nil

json.(playlist, :id, :name)
json.cover playlist.cover_url || ''
json.is_followed playlist.is_followed(user.try(:id))
json.tracks do
  json.array! playlist.tracks, partial: 'boombox/v1/tracks/track', as: :track
end
