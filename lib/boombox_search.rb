module BoomboxSearch
  extend self

  def query_search(key)
    collaborators = Collaborator.verified.search(key).records.to_a
    activities = BoomActivity.is_display.search(key).records.to_a
    playlists = BoomPlaylist.playlist.open.search(key).records.to_a
    tracks = BoomTrack.valid.search(key).records.to_a

    {
      collaborators: collaborators,
      activities: activities,
      playlists: playlists,
      tracks: tracks
    }
  end
end
