module BoomboxSearch
  extend self

  def query_search(key)
    collaborators = Collaborator.search(key).records.to_a
    activities = BoomActivity.search(key).records.to_a
    playlists = BoomPlaylist.search(key).records.to_a
    tracks = BoomTrack.search(key).records.to_a
    tags = BoomTag.search(key).records.to_a

    if tags.present?
      collaborators = collaborators | tags.collect{|tag| tag.collaborators}.flatten
      activities = activities | tags.collect{|tag| tag.activities}.flatten
      playlists = playlists | tags.collect{|tag| tag.playlists}.flatten
      tracks = tracks | tags.collect{|tag| tag.tracks}.flatten
    end

    {
      collaborators: collaborators,
      activities: activities,
      playlists: playlists,
      tracks: tracks
    }
  end
end
