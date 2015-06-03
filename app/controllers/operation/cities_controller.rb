# encoding: utf-8
class Operation::CitiesController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_city, except: [:index, :search]
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    @cities = City.page(params[:page])
  end

  def search
    params[:page] ||= 1
    @cities = City.where("name like ?", "%#{params[:q]}%").page(params[:page]).order("created_at desc")
    render :index
  end

  def stadiums_list
    @stadiums = @city.stadiums
  end

  private
  def get_city
    @city = City.find(params[:city_id])
  end
end
