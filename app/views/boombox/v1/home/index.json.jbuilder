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
    json.(colla, :id, :name)
    json.cover colla.cover_url || ''
  end
end

json.radios do
  json.array! @radios do |playlist|
    json.(playlist, :id, :name)
    json.cover playlist.cover_url || ''
    json.is_followed playlist.is_followed(@user.try(:id))
    json.tracks do
      json.array! playlist.tracks.order('RAND()'), partial: 'boombox/v1/tracks/track', as: :track
    end
  end
end

json.playlists do
  json.array! @playlists, partial: 'boombox/v1/playlists/playlist', as: :playlist, user: @user
end
