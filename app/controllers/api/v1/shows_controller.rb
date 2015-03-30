class Api::V1::ShowsController < Api::V1::ApplicationController
  def index
    params[:page] ||= 1
    @shows = Show.page(params[:page])
  end

  def show
    @show = Show.find(params[:id])
  end
end
