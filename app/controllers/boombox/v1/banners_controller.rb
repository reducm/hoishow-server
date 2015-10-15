class Boombox::V1::BannersController < Boombox::V1::ApplicationController
  def index
    @banners = BoomBanner.all
  end
end
