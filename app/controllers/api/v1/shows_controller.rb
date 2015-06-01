# encoding: utf-8
class Api::V1::ShowsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    params[:page] ||= 1
    @shows = Show.is_display.page(params[:page])
  end

  def show
    @show = Show.find(params[:id])
  end

  def preorder
    @show = Show.find(params[:id])
    @stadium = @show.stadium
  end
end
