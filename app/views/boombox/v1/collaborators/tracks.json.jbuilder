json.tracks do
  json.array! @tracks, partial: 'boombox/v1/tracks/track', as: :track, user: @user
end

json.track_count @collaborator.track_count
