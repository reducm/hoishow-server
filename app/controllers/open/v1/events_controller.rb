# encoding: utf-8
require "bmp_reader"
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
    render layout: "mobile"
  end
end
