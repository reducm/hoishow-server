# encoding: utf-8
class Operation::CitiesController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_city, except: [:index, :new, :create, :search]
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    params[:page] ||= 1
    @cities = City.order(created_at: :desc).page(params[:page])
  end

  def new
    @city = City.new
  end

  def create
    @city = City.new(city_params)
    if @city.save
      redirect_to operation_cities_url
    else
      render :new
    end
  end

  def edit
  end

  def update
    if @city.update(city_params)
      redirect_to operation_cities_url
    else
      render :edit
    end
  end

  def search
    params[:page] ||= 1
    @cities = City.where("name like :search or pinyin like :search", search: "%#{params[:q]}%").order("created_at desc").page(params[:page])
    render :index
  end

  def stadiums_list
    @stadiums = @city.stadiums
  end

  private
  def get_city
    @city = City.find(params[:id])
  end

  def city_params
    params.require(:city).permit(:name, :pinyin, :is_hot)
  end
end
