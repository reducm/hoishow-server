# encoding: utf-8
class Open::V1::ApplicationController < ApplicationController

  protected
  def show_auth!
    @show = Show.where(id: params[:show_id]).first
    if @show.nil?
      not_found_respond('找不到该演出')
    end
  end

  def area_auth!
    show_auth!
    @area = @show.areas.where(id: params[:area_id]).first
    if @area.nil?
      not_found_respond('找不到该区域')
    end
  end

  def not_found_respond(msg)
    @error_code = 4004
    @message = msg
    respond_to { |f| f.json }
  end

end
