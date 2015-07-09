# encoding: utf-8
class Open::V1::ShowsController < Open::V1::ApplicationController
  # 演出列表
  def index
    @shows = Show.all
  end

  # 演出信息查询
  def show
    @show = Show.where(id: params[:id]).first
    if @show.nil?
      not_found_respond('找不到该演出')
    end
  end
end
