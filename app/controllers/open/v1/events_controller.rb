# encoding: utf-8
require "get_bmp_coordinate"
class Open::V1::EventsController < Open::V1::ApplicationController
  before_action :show_auth!, only: [:index]
  skip_before_filter :api_verify!, only: [:areas_map]
  skip_before_filter :find_auth!, only: [:areas_map]
  def index
    @events = @show.events.verified
  end

  def areas_map
    @event = Event.find_by_id(params[:id])
    @show = @event.show
    read_bmp = BMP::Reader.new(@event.coordinate_map_url)
    @map_width = read_bmp.width
    @map_height = read_bmp.height
    valid_areas = @event.areas.where("left_seats != 0").pluck(:coordinates)
    all_areas = Rails.cache.fetch("#{@event.id}_all_areas_coodinates") do
      draw_image(@event.coordinate_map_url)
    end.values
    all_areas.pop(2)
    @invalid_areas = all_areas - valid_areas
    render layout: "mobile"
  end

  def today_shows
    @today_event_shows = Show.where('updated_at > ?', DateTime.now.beginning_of_day).is_display
  end
end
