# encoding: utf-8
class Api::V1::StarsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    @stars = Star.is_display
  end

  def show
    @star = Star.find(params[:id])
  end

  def search
    @stars = Star.is_display.search params[:q]
  end
end
