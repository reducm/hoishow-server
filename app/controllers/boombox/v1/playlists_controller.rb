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
    render partial: 'playlist', locals: {playlist: @playlist}
  end
end
