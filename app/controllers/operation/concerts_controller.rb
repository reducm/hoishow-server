# encoding: utf-8
class Operation::ConcertsController < Operation::ApplicationController
  include Operation::ConcertsHelper
  before_action :check_login!, except: [:get_city_voted_data, :get_cities]
  before_action :get_concert, except: [:index, :new, :create, :search]
  load_and_authorize_resource param_method: :concert_attributes
  skip_authorize_resource :only => [:get_city_voted_data, :get_cities]

  def index
    params[:page] ||= 1
    @concerts = Concert.concerts_without_auto_hide.page(params[:page]).order("created_at desc")
    respond_to do |format|
      format.html
      format.xls
    end
  end

  def search
    params[:page] ||= 1
    star_ids = Star.where("name like ?", "%#{params[:q]}%").map(&:id).compact
    concert_ids = StarConcertRelation.where("star_id in (?)", star_ids).map(&:concert_id).compact
    @concerts = Concert.concerts_without_auto_hide.where("name like ? or id in (?)", "%#{params[:q]}%", concert_ids).page(params[:page]).order("created_at desc")
    render :index
  end

  def edit
    @concert_shows = @concert.shows.page(params[:page])
  end

  def update
    if @concert.update(concert_attributes)
      redirect_to operation_concerts_url
    else
      flash[:alert] = @concert.errors.full_messages
      render :edit
    end
  end

  def new
    @concert = Concert.new
    @star = Star.find(params[:star_id])
  end

  def create
    @concert = Concert.new(concert_attributes)
    star = Star.find(params[:star_id])
    if @concert.save && star
      star.hoi_concert(@concert)
      users_array = star.followers
      message = Message.new(send_type: "new_concert", creator_type: "Star", creator_id: star.id, subject_type: "Concert", subject_id: @concert.id, notification_text: "你关注的艺人发布了一个新的演出众筹", title: "新的演出众筹", content: "#{star.name}刚刚发布了一个新的演出众筹，还等什么，快来投票吧！")
      if ( result = message.send_umeng_message(users_array, message, none_follower: "演出创建成功，但是因为艺人粉丝数为0，所以消息创建失败")) != "success"
        flash[:alert] = result
      end
    else
      flash[:alert] = @concert.errors.full_messages
    end
    redirect_to action: :index
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
    @topics = @concert.topics.where(subject_type: Topic::SUBJECT_CONCERT).page(params[:page]).per(5)
    @topics = @topics.where(city_id: params[:city_id]).page(params[:page]).per(5) if params[:city_id]

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

  def toggle_is_top
    if @concert.is_top
      @concert.update(is_top: false)
    else
      @concert.update(is_top: true)
    end
    redirect_to operation_concerts_url
  end

  def update_base_number
    if ConcertCityRelation.where(concert_id: params[:concert_id], city_id: params[:city_id]).first.update(base_number: params[:base_number])
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def add_star
    star = Star.find_by_id([params[:star_id]])
    if star
      star.hoi_concert(@concert)
      render json: {success: true}
    else
      render json: {success: false}
    end
  end

  def remove_star
    relation = @concert.star_concert_relations.where(star_id: params[:star_id]).first
    if relation
      relation.destroy
      render json: {success: true}
    else
      render json: {success: false}
    end
  end


  private
  def concert_attributes
    params.require(:concert).permit(:name, :is_show, :status, :start_date, :end_date, :description, :poster)
  end

  def get_concert
    @concert = Concert.find(params[:id])
  end
end
