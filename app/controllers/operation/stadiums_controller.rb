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

  def edit
    @city = @stadium.city
  end

  def update
    if @stadium.update(stadium_params)
      redirect_to operation_stadiums_url(city_id: @stadium.city_id)
    else
      render edit_operation_stadium_url
    end
  end
  
  def refresh_areas
    render partial: 'operation/areas/stadium_areas_table', locals: {stadium: @stadium, areas: @stadium.areas}
  end
  
  def submit_area
    if params[:area_id].present?
      @area = @stadium.areas.where(id: params[:area_id]).first
      @area.name = params[:area_name]
    else
      @area = @stadium.areas.new(name: params[:area_name])
    end
    if @area.save
      render json: {success: true}
    else
      render json: {error: true}
    end
  end
  
  def del_area
    @area = @stadium.areas.where(id: params[:area_id]).first
    if @area.destroy
      render json: {success: true}
    else
      render json: {error: true}
    end
  end

  private
  def get_stadium
    @stadium = Stadium.find(params[:id])
  end

  def stadium_params
    params.require(:stadium).permit(:name, :address, :longitude, :latitude, :city_id, :pic)
  end
end
