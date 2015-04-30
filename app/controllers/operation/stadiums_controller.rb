class Operation::StadiumsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_stadium, except: [:index, :new, :create]
  load_and_authorize_resource

  def index
    @city = City.find params[:city_id]
    @stadiums = @city.stadiums
  end

  def new
    @stadium = Stadium.new
    @city = City.find params[:city_id]
  end

  def create
    @stadium = Stadium.new(stadium_params)
    if @stadium.save
      redirect_to operation_stadiums_url(city_id: stadium_params[:city_id])
    else
      render new_operation_stadium_url(city_id: stadium_params[:city_id])
    end
  end

  def show
  end

  def edit
  end

  def update
  end

  private
  def get_stadium
    @stadium = Stadium.find(params[:id])
  end

  def stadium_params
    params.require(:stadium).permit(:name, :address, :longitude, :latitude, :city_id, :pic)
  end
end
