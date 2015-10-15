class SeatsMapController < ApplicationController
  layout false

  def show
    @show = Show.find_by_id(params[:show_id])
    @area = @show.areas.find_by_id(params[:area_id])
    seats_info = @area.seats_info
    if seats_info
      @seats = seats_info['seats']
      total = seats_info['total'].split('|').map(&:to_i)
      @max_row = total[0]
      @max_col = total[1]
      @sort_by = seats_info['sort_by']
    end
  end
end
