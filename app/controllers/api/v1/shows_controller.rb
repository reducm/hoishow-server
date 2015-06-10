# encoding: utf-8
class Api::V1::ShowsController < Api::V1::ApplicationController
  before_action :check_has_user
  before_action :get_show, except: [:index]
  skip_before_filter :api_verify, only: [:click_seat]

  def index
    params[:page] ||= 1
    @shows = Show.is_display.page(params[:page])
  end

  def show
  end

  def preorder
    @stadium = @show.stadium
  end

  def seats_info
    @area = @show.areas.find_by_id(params[:area_id])
  end

  def click_seat
    render nothing: true
  end

  private
  def get_show
    @show = Show.find(params[:id])
  end
end
