user ||= nil
need_tracks ||= false

json.(playlist, :id, :name)
json.cover playlist.cover_url || ''
json.is_followed playlist.is_followed(user.try(:id))
json.tracks_count playlist.tracks_count

if playlist.creator_type == BoomPlaylist::CREATOR_COLLABORATOR && playlist.creator
  json.collaborator do
    json.name playlist.creator.name
    json.avatar playlist.creator.cover_url || ''
  end
else
  json.collaborator nil
end

if need_tracks
  json.tracks do
    json.array! tracks, partial: 'boombox/v1/tracks/track', as: :track
  end
end
