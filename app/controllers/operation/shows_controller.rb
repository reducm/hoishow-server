class Operation::ShowsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_show, except: [:index, :new, :create, :get_city_stadiums]
  load_and_authorize_resource

  def index
    @shows = Show.all
  end

  def new
    @show = Show.new
    if params[:concert_id]
      @concert = Concert.find(params[:concert_id])
    end
  end

  def create
    @show = Show.new(show_params)
    if @show.save
      redirect_to action: :index
    else
      flash[:error] = @show.errors.full_messages
      redirect_to new_operation_show_url(concert_id: params[:show][:concert_id])
    end
  end

  def show
  end

  def edit
    @concert = @show.concert
  end

  def update
    if @show.update!(show_params)
      redirect_to operation_shows_url
    else
      flash[:error] = @show.errors.full_messages
      render :edit
    end
  end

  def get_city_stadiums
    data = City.find(params[:city_id]).stadiums.select(:name, :id, :pic).map {|stadium| {name: stadium.name, id: stadium.id, pic: stadium.pic.url}}
    render json: data
  end

  def update_area_data
    if ShowAreaRelation.where(show_id: params[:show_id], area_id: params[:area_id]).first.update!(price: params[:price], seats_count: params[:seats_count])
    else
      flash[:error] = "更新区域数据失败！！！"
    end
    render partial: "area_table", locals:{show: @show}
  end

  protected
  def show_params
    params.require(:show).permit(:name, :show_time, :city_id, :stadium_id, :description, :concert_id)
  end

  def get_show
    @show = Show.find(params[:id])
  end
end
