# encoding: utf-8
class Api::V1::ConcertsController < Api::V1::ApplicationController
  before_action :check_has_user
  def index
    params[:page] ||= 1
    @concerts = Concert.showing_concerts.page(params[:page])
  end

  def show
    @concert = Concert.find(params[:id])
  end

  def city_rank
    @concert = Concert.find(params[:id])
    shows = @concert.shows
    @cities = shows.any? ? @concert.cities.where('city_id not in (?)', shows.map(&:city_id)) : @concert.cities
  end
end
