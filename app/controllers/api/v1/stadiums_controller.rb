class Api::V1::StadiumsController < Api::V1::ApplicationController
  def index
    params[:page] ||= 1
    @stadiums = Stadium.page(params[:page])
  end 
end
