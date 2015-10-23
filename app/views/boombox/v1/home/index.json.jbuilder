@user ||= nil

json.banners do
  json.array! @banners do |banner|
    json.(banner, :id, :subject_type, :subject_id)
    json.poster banner.poster_url || ''
  end
end

json.tracks do
  json.array! @tracks, partial: 'boombox/v1/tracks/track', as: :track
end

json.collaborators do
  json.array! @collaborators do |colla|
    json.(colla, :id, :name, :followed_count)
    json.cover colla.cover_url || ''
  end
end

json.radios do
  json.array! @radios, partial: 'boombox/v1/playlists/playlist', as: :playlist, user: @user
end

json.playlists do
  json.array! @playlists, partial: 'boombox/v1/playlists/playlist', as: :playlist, user: @user
end
