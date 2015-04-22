class Operation::ConcertsController < Operation::ApplicationController
  include Operation::ConcertsHelper
  before_action :check_login!, except: [:get_city_voted_data]
  before_action :get_concert, except: [:index]
  load_and_authorize_resource
  skip_authorize_resource :only => [:get_city_voted_data]

  def index
    if params[:q]
      @stars = Star.search(params[:q])
      @concerts = @stars.map{|star| star.concerts}.flatten.page(params[:page])
    elsif params[:p].present?
      @concerts = Concert.where(status: params[:p]).page(params[:page])
    else
      @concerts = Concert.page(params[:page])
    end
  end

  def show

  end

  def edit
  end

  def update
    if @concert.update!(validate_attributes)
      redirect_to operation_concerts_url
    else
      flash[:notice] = @concert.errors.full_messages
      render :edit
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

  def get_city_topics
    @topics = @concert.topics.where(city_id: params[:city_id]).page(params[:page]).per(5)
    respond_to do |format|
      format.js
    end
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
