class Operation::ConcertsController < Operation::ApplicationController
  include Operation::ConcertsHelper
  before_action :check_login!, except: [:get_city_voted_data]
  before_action :get_concert, except: [:index]
  load_and_authorize_resource
  skip_authorize_resource :only => [:get_city_voted_data]

  def index
    @concerts = Concert.page(params[:page])
  end

  def edit
    @concert_shows = @concert.shows.page(params[:page])
  end

  def update
    if @concert.update!(validate_attributes)
      redirect_to operation_concerts_url
    else
      flash[:notice] = @concert.errors.full_messages
      render :edit
    end
  end

  def new 
    @concert = Concert.new
  end

  def create
  end

  def refresh_map_data
    render partial: "city_voted_data", locals: {concert: @concert}
  end

  def add_concert_city
    relation = @concert.concert_city_relations.new(city_id: params[:city_id])
    if relation.save
      render json: {success: true}
    else
      render json: {error: true}
    end
  end

  def remove_concert_city
    relation = @concert.concert_city_relations.where(city_id: params[:city_id]).first
    if relation
      relation.destroy
      render json: {success: true}
    else
      render json: {error: true}
    end
  end

  def get_city_topics
    @city = City.find(params[:city_id])
    @topics = Topic.where(subject_type: Topic::SUBJECT_CONCERT, city_id: @city.id).page(params[:page]).per(5)
    @subject_type = Topic::SUBJECT_CONCERT
  end

  def get_city_voted_data
    data = @concert.cities.map{|city| {name: city.name, value: get_city_voted_count(city)}}
    render json: data
  end

  private
    def validate_attributes
      params.require(:concert).permit(:name, :status, :start_date, :end_date, :description)
    end

    def get_concert
      @concert = Concert.find(params[:id])
    end
end
