# encoding: utf-8
class Open::V1::AreasController < Open::V1::ApplicationController
  before_action :show_auth!
  # 区域列表
  def index
    @areas = @show.areas.all
  end

  # 区域信息查询
  def show
    @area = @show.areas.where(id: params[:id]).first
    if @area.nil?
      not_found_respond('找不到该区域')
    end
  end
end
