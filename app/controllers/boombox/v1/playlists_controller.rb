class Boombox::V1::PlaylistsController < Boombox::V1::ApplicationController
  before_action :get_user

  def radio_list
    @radios = BoomPlaylist.open.radio
  end

  def playlist_list
    @playlists = BoomPlaylist.open.playlist
  end

  def show
    @playlist = BoomPlaylist.find_by_id params[:id]
    render partial: 'playlist', locals: {playlist: @playlist}
  end
end
