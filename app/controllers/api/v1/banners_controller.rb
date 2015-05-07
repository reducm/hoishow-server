class Api::V1::BannersController < Api::V1::ApplicationController
  def index
    @banners = Banner.all
  end
end
