class Boombox::V1::PlaylistsController < Boombox::V1::ApplicationController
  before_action :get_user

  def radio_list
    @radios = BoomPlaylist.open.radio
  end

  def playlist_list
    if params[:keyword]
      @playlists = BoomboxSearch.query_search(params[:keyword])[:playlists]
    else
      @playlists = BoomPlaylist.recommend(@user)
    end
    @playlists = Kaminari.paginate_array(@playlists).page(params[:page]).per(10)
  end

  def show
    @playlist = BoomPlaylist.find_by_id params[:id]
    @tracks = case
              when @playlist.radio?
                @playlist.tracks.order('RAND()')
              when @playlist.playlist? && params[:is_all]
                @playlist.tracks.order('playlist_track_relations.created_at desc')
              when @playlist.playlist?
                @playlist.tracks.order('playlist_track_relations.created_at desc').page(params[:page])
              end
    render partial: 'playlist', locals: {playlist: @playlist, user: @user, tracks: @tracks, need_tracks: true}
  end
end
