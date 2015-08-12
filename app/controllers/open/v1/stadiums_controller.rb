# encoding: utf-8
class Open::V1::StadiumsController < Open::V1::ApplicationController
  # 场馆列表
  def index
    @stadiums = Stadium.all
  end

  # 场馆信息查询
  def show
    @stadium = Stadium.find(params[:id])
  end
end
