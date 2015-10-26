class Boombox::V1::HomeController < Boombox::V1::ApplicationController
  before_action :get_user

  def index
    @banners = BoomBanner.all
    @tracks = BoomTrack.recommend.limit(3)
    @collaborators = Collaborator.display.limit(4)
    @radios = BoomPlaylist.radio.open.limit(6)
    @playlists = BoomPlaylist.playlist.open.limit(3)
  end
end
