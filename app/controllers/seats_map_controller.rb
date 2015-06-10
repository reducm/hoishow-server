class SeatsMapController < ApplicationController
  layout false
  def show
    @show = Show.find_by_id(params[:show_id])
    @area = @show.areas.find_by_id(params[:area_id])
    @seats = @show.seats.where(area_id: @area.id)
  end
end
