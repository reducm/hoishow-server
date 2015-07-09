# encoding: utf-8
class Open::V1::StadiumsController < Open::V1::ApplicationController
  # 场馆列表
  def index
    @stadiums = Stadium.all
  end

  # 场馆信息查询
  def show
    @stadium = Stadium.where(id: params[:id]).first
    if @stadium.nil?
      not_found_respond('找不到该场馆')
    end
  end
end
