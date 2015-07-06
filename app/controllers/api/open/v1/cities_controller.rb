# encoding: utf-8
class Api::Open::V1::CitiesController < Api::Open::V1::ApplicationController
  def index
    @cities = City.all
  end  
end
