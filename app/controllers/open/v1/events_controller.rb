# encoding: utf-8
require "get_bmp_coordinate"
class Open::V1::EventsController < Open::V1::ApplicationController
  before_action :show_auth!, only: [:index] 
  skip_before_filter :api_verify!, only: [:areas_map]
  skip_before_filter :find_auth!, only: [:areas_map]
  def index
    @events = @show.events.all
  end

  def areas_map
    @event = Event.find_by_id(params[:id])
    @show = @event.show
    read_bmp = BMP::Reader.new(@event.coordinate_map_url)
    @map_width = read_bmp.width
    @map_height = read_bmp.height
    valid_areas = @event.areas.where("left_seats != 0").pluck(:coordinates)
    @invalid_areas = draw_image(@event.coordinate_map_url).values - valid_areas
    @invalid_areas.pop
    @invalid_areas.pop
    render layout: "mobile"
  end
end
