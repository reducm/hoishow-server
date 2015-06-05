class SeatsMapController < ApplicationController
  layout false
  def show
    @show = Show.find_by_id(params[:show_id])
    @area = @show.areas.find_by_id(params[:area_id])
    seat = @show.seats.where(area_id: @area.id).first
    @seats_info = JSON.parse seat.seats_info if seat
  end
end
