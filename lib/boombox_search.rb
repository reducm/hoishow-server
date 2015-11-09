module BoomboxSearch
  SEARCH_MODELS = [BoomTag, Collaborator, BoomPlaylist, BoomTrack, BoomActivity]

  def query_search(key)
    records = Elasticsearch::Model.search(key, SEARCH_MODELS).records
    wrap_result(records)
  end

  def wrap_result(records)
    @collaborators=@activities=@playlists=@tracks=[]
    records.group_by{|r| r.model_name.collection}.each do |k, v|
      case k
      when 'collaborators'
        @collaborators = v
      when 'boom_activities'
        @activities = v
      when 'boom_playlists'
        @playlists = v
      when 'boom_tracks'
        @tracks = v
      else
        @tags = v
      end
    end

    if @tags.present?
      @collaborators = @collaborators | @tags.collect{|tag| tag.collaborators}.flatten
      @activities = @activities | @tags.collect{|tag| tag.activities}.flatten
      @playlists = @playlists | @tags.collect{|tag| tag.playlists}.flatten
      @tracks = @tracks | @tags.collect{|tag| tag.tracks}.flatten
    end
  end
end
