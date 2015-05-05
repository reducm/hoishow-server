class Api::V1::ConcertsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    params[:page] ||= 1
    @concerts = Concert.page(params[:page])
  end

  def show
    @concert = Concert.find(params[:id])
  end

  def city_rank
    @concert = Concert.find(params[:id])
    @cities = @concert.cities
  end
end
