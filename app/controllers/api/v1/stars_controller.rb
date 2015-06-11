# encoding: utf-8
class Api::V1::StarsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    params[:page] ||= 1
    @stars = Star.is_display.page(params[:page])
  end

  def show
    @star = Star.find(params[:id])
  end

  def search
    @stars = Star.is_display.search params[:q]
  end

  def star_concerts_and_shows
    params[:page] ||= 1
    @star = Star.find(params[:id])
    @concerts_and_shows_array = Kaminari.paginate_array(( @star.concerts + @star.shows ).sort{|a, b| b.created_at <=> a.created_at}).page(params[:page]).per(10)
  end
end
