# encoding: utf-8
class Api::V1::StarsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    params[:page] ||= 1
    @stars = Star.is_display.order(:position).page(params[:page])
  end

  def show
    @star = Star.find(params[:id])
  end

  def search
    @stars = Star.is_display.order(:position).search params[:q]
  end
end
