user ||= nil
need_tracks ||= false
need_track_ids ||= false

json.(playlist, :id, :name)
json.cover playlist.current_cover_url || ''
json.is_followed playlist.is_followed(user.try(:id))
json.is_default playlist.is_default
json.tracks_count playlist.tracks_count

co = playlist.creator
if playlist.creator_type == BoomPlaylist::CREATOR_COLLABORATOR && co
  json.collaborator do
    json.id co.id
    json.name co.display_name
    json.avatar co.avatar_url || ''
  end
else
  json.collaborator nil
end

if need_tracks
  json.tracks do
    json.array! tracks.where(removed: false), partial: 'boombox/v1/tracks/track', as: :track, user: user
  end
end

if need_track_ids
  json.track_ids playlist.tracks.ids
end
