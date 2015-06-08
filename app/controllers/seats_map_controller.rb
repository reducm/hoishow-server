class SeatsMapController < ApplicationController
  layout false
  def show
    @show = Show.find_by_id(params[:show_id])
    @area = @show.areas.find_by_id(params[:area_id])
    @seats_info = @area.seats_info(@show.id)
  end
end
