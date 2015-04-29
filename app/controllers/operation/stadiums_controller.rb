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
  end

  def create
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
end
