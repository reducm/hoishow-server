# encoding: utf-8
class Api::V1::CitiesController < Api::V1::ApplicationController
  def index
    params[:page] ||= 1
    @cities = City.page(params[:page])
  end  
end
