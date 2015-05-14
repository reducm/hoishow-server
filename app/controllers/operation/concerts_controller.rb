class Operation::ConcertsController < Operation::ApplicationController
  include Operation::ConcertsHelper
  before_action :check_login!, except: [:get_city_voted_data, :get_cities]
  before_action :get_concert, except: [:index, :new, :create]
  #load_and_authorize_resource except: [:create]
  load_and_authorize_resource param_method: :concert_attributes
  skip_authorize_resource :only => [:get_city_voted_data, :get_cities]

  def index
    @concerts = Concert.all
  end

  def edit
    @concert_shows = @concert.shows.page(params[:page])
  end

  def update
    if @concert.update(concert_attributes)
      redirect_to operation_concerts_url
    else
      flash[:error] = @concert.errors.full_messages
      render :edit
    end
  end

  def new
    @concert = Concert.new
  end

  def create
    @concert = Concert.new(concert_attributes)
    if @concert.save
      redirect_to action: :index
    else
      flash[:error] = @concert.errors.full_messages
      render :new
    end
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
    @topics = Topic.where(subject_type: Topic::SUBJECT_CONCERT).page(params[:page]).per(5)
    @topics = @topics.where(city_id: params[:city_id]) if params[:city_id]

    render partial: 'operation/topics/table', locals: {topics: @topics}
  end

  def get_city_voted_data
    data = @concert.cities.map{|city| {name: city.name, value: get_city_voted_count(@concert, city)}}
    render json: data
  end

  def get_cities
    cities = get_no_concert_cities(@concert)

    if params[:term]
      cities = cities.where("name LIKE ? or pinyin LIKE ?", "%#{params[:term]}%", "%#{params[:term]}%")
    end

    render json: cities.map{|city| {value: city.id, label: city.name}}
  end

  private
    def concert_attributes
      params.require(:concert).permit(:name, :is_show, :status, :start_date, :end_date, :description)
    end

    def get_concert
      @concert = Concert.find(params[:id])
    end
end
