class Boombox::V1::HomeController < Boombox::V1::ApplicationController
  before_action :get_user

  def index
    @banners = BoomBanner.all
    @collaborators = Collaborator.verified.limit(4)
    @radios = BoomPlaylist.radio.open.limit(6)
    @tracks = BoomTrack.recommend(@user).first(3)
    @playlists = @user ? @user.recommend_playlists.first(3) : BoomPlaylist.playlist.open.limit(3)
  end
end
