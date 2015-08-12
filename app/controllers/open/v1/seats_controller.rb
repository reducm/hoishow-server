# encoding: utf-8
class Open::V1::SeatsController < Open::V1::ApplicationController
  before_action :show_auth!, :area_auth!
  # 座位列表
  def index
    @seats = Seat.where(show_id: @show.id, area_id: @area.id) # some channel
  end

  # 座位信息查询
  def show
    @seat = Seat.where(show_id: @show.id, area_id: @area.id, id: params[:id]).first # some channel
    if @seat.nil?
      not_found_respond('找不到该座位')
    end
  end
end
