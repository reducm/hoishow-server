class Api::V1::BannersController < ApplicationController
  def index
    @banners = Banner.all
  end
end
