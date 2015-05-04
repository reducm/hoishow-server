class Operation::ShowsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @shows = Show.page(params[:page])
  end

  def show
    @show = Show.find(params[:id])
  end

  def edit
    @show = Show.find(params[:id])
  end

  def update

  end
  
  def create
    @show = Show.new(show_params)
    if @show.save
      redirect_to action: :index
    else
      redirect_to new_operation_show_url(concert_id: params[:show][:concert_id])
    end
  end

  def new
    @show = Show.new
    if params[:concert_id]
      @concert = Concert.find(params[:concert_id])
    end
  end

  def get_city_stadiums
    data = City.find(params[:city_id]).stadiums.select(:name, :id).map {|stadium| {name: stadium.name, id: stadium.id}}
    render json: data
  end

  protected
  def show_params
    params.require(:show).permit(:name, :show_time, :city_id, :stadium_id, :description, :concert_id)
  end

end
