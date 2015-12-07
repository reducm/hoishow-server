@user ||= nil

json.array! @radios do |playlist|
  json.(playlist, :id, :name)
  json.cover playlist.cover_url || ''
  json.is_followed playlist.is_followed(@user.try(:id))
  json.track_ids playlist.tracks.ids
  json.tracks do
    json.array! playlist.tracks.order('RAND()'), partial: 'boombox/v1/tracks/track', as: :track
  end
end
