@user ||= nil

json.banners do
  json.array! @banners do |banner|
    json.(banner, :id, :subject_type, :subject_id)
    json.poster banner.poster_url || ''
    if banner.subject && banner.subject_type == 'BoomActivity' && banner.subject.activity?
      json.title banner.subject_name
      json.description description_boombox_v1_activity_url(banner.subject)
    end
  end
end

json.tracks do
  json.array! @tracks, partial: 'boombox/v1/tracks/track', as: :track
end

json.collaborators do
  json.array! @collaborators do |colla|
    json.(colla, :id)
    json.name colla.display_name
    json.cover colla.cover_url || ''
  end
end

json.radios do
  json.array! @radios, partial: 'boombox/v1/playlists/playlist', as: :playlist, user: @user
end

json.playlists do
  json.array! @playlists, partial: 'boombox/v1/playlists/playlist', as: :playlist, user: @user
end
