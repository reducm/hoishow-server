class Boombox::V1::PlaylistsController < Boombox::V1::ApplicationController
  before_action :get_user

  def radio_list
    @radios = BoomPlaylist.open.radio
  end

  def playlist_list
    if params[:keyword]
      @playlists = BoomboxSearch.query_search(params[:keyword])[:playlists]
      @playlists = Kaminari.paginate_array(@playlists).page(params[:page]).per(10)
    else
      @playlists = BoomPlaylist.open.playlist.page(params[:page])
    end
  end

  def show
    @playlist = BoomPlaylist.find_by_id params[:id]
    @tracks = case
              when @playlist.radio?
                @playlist.tracks.order('RAND()')
              when @playlist.playlist? && params[:is_all]
                @playlist.tracks.order('playlist_track_relations.created_at')
              when @playlist.playlist?
                @playlist.tracks.order('playlist_track_relations.created_at').page(params[:page])
              end
    render partial: 'playlist', locals: {playlist: @playlist, user: @user, tracks: @tracks, need_tracks: true}
  end
end
