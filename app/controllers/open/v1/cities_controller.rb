# encoding: utf-8
class Open::V1::CitiesController < Open::V1::ApplicationController
  # 城市列表
  def index
    @cities = City.all
  end
end
