# encoding: utf-8
class Open::V1::AreasController < Open::V1::ApplicationController
  before_action :show_auth!
  # 区域列表
  def index
    @areas = @show.areas.all
  end

  # 区域信息查询
  def show
    @area = @show.areas.find(params[:id])
  end

  # 座位信息查询
  def seats_info
    area = @show.areas.find(params[:id])
    seats_info = area.seats_info
    seats_hash = seats_info["seats"]
    result = []
    seats_hash.each do |row, row_info|
      row_info.each do |column, seat_info|
        result.push({
          "row": row,
          "column": column,
          "name": seat_info["seat_no"],
          "price": seat_info["price"],
          "status": seat_info["status"]
        })
      end
    end
    return render json: { result_code: 0, data: result, message: 'ok' }
  end
end
