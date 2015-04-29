class Api::V1::AreasController < Api::V1::ApplicationController
  def index
    params[:page] ||= 1
    @areas = Area.page(params[:page])
  end 
end
