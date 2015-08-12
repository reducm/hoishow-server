# encoding: utf-8
class Open::V1::AreasController < Open::V1::ApplicationController
  before_action :show_auth!
  # 区域列表
  def index
    @areas = @show.areas.includes(:seats).all
  end

  # 区域信息查询
  def show
    @area = @show.areas.includes(:seats).find(params[:id])
  end
end
