# encoding: utf-8
class Open::V1::ShowsController < Open::V1::ApplicationController
  # 演出列表
  def index
    error_respond(403, '缺少城市id') unless params[:city_id].present?
    @shows = Show.where(city_id: params[:city_id]).is_display
  end

  # 演出信息查询
  def show
    @show = Show.find(params[:id])
  end
end
