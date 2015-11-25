module BoomboxSearch
  extend self

  def query_search(key)
    collaborators = Collaborator.search(key).records.verified.to_a
    activities = BoomActivity.search(key).records.is_display.to_a
    playlists = BoomPlaylist.search(key).records.playlist.open.to_a
    tracks = BoomTrack.search(key).records.valid.to_a

    {
      collaborators: collaborators,
      activities: activities,
      playlists: playlists,
      tracks: tracks
    }
  end
end
