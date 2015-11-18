module BoomboxSearch
  extend self

  def query_search(key)
    collaborators = Collaborator.search(key).records.to_a
    activities = BoomActivity.search(key).records.to_a
    playlists = BoomPlaylist.search(key).records.to_a
    tracks = BoomTrack.search(key).records.to_a

    {
      collaborators: collaborators,
      activities: activities,
      playlists: playlists,
      tracks: tracks
    }
  end
end
