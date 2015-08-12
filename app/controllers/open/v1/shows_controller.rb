# encoding: utf-8
class Open::V1::ShowsController < Open::V1::ApplicationController
  # 演出列表
  def index
    @shows = Show.all
  end

  # 演出信息查询
  def show
    @show = Show.find(params[:id])
  end
end
