user ||= nil
need_tracks ||= false
need_track_ids ||= false

json.(playlist, :id, :name)
json.cover playlist.cover_url || ''
json.is_followed playlist.is_followed(user.try(:id))
json.is_default playlist.is_default
json.tracks_count playlist.tracks_count

if playlist.creator_type == BoomPlaylist::CREATOR_COLLABORATOR && playlist.creator
  json.collaborator do
    json.name playlist.creator.display_name
    json.avatar playlist.creator.cover_url || ''
  end
else
  json.collaborator nil
end

if need_tracks
  json.tracks do
    json.array! tracks, partial: 'boombox/v1/tracks/track', as: :track, user: user
  end
end

if need_track_ids
  json.track_ids playlist.tracks.ids
end
