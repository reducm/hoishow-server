class Boombox::V1::PlaylistsController < Boombox::V1::ApplicationController
  before_action :get_user

  def radio_list
    @radios = BoomPlaylist.open.radio
  end

  def playlist_list
    @playlists = BoomPlaylist.open.playlist
  end
end
