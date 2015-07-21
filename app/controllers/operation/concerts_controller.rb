# encoding: utf-8

class Operation::ConcertsController < Operation::ApplicationController
  include Operation::ConcertsHelper
  before_action :check_login!, except: [:get_city_voted_data, :get_cities]
  before_action :get_concert, except: [:index, :new, :create]
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    params[:page] ||= 1
    #有搜索关键字时
    if params[:q]
      star_ids = Star.where("name like ?", "%#{params[:q]}%").map(&:id).compact
      concert_ids = StarConcertRelation.where("star_id in (?)", star_ids).map(&:concert_id).compact
      @concerts = Concert.concerts_without_auto_hide.where("name like ? or id in (?)", "%#{params[:q]}%", concert_ids).page(params[:page]).order("created_at desc")
    else
      @concerts = Concert.concerts_without_auto_hide.page(params[:page]).order("created_at desc")
    end
    #下拉框筛选
    case params[:concert_status_select]
    when "voting"
      @concerts = @concerts.where(status: 0)
    when "finished"
      @concerts = @concerts.where(status: 1)
    end
    #导出
    filename = Time.now.strfcn_time + '投票列表'
    respond_to do |format|
      format.html { render :index }
      format.csv { send_data @concerts.to_csv, filename: filename + '.csv'}
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xls\""}
    end
  end

  def new
    @concert = Concert.new
    if Star.first
      @star = params[:star_id] ? Star.find(params[:star_id]) : Star.first
    else
      flash[:alert] = "尚未有艺人，请先新建艺人"
      redirect_to new_operation_star_url
    end
  end

  def create
    @concert = Concert.new(concert_params)
    if @concert.save
      Star.where('id in (?)', params[:star_ids].split(',')).each{|star| star.hoi_concert(@concert)}
      flash[:notice] = '投票创建成功'
      redirect_to edit_operation_concert_url(@concert, from_create: 1)
    else
      flash[:alert] = @concert.errors.full_messages
      render action: 'new'
    end
  end

  def edit
    @concert_shows = @concert.shows.page(params[:page])
    @stars = @concert.stars
  end

  def update
    if @concert.update(concert_params)
      flash[:notice] = '投票修改成功'
      redirect_to operation_concerts_url
    else
      flash[:alert] = @concert.errors.full_messages
      render :edit
    end
  end

  def send_create_message
    users_array = @concert.stars.map{|star| star.followers}.flatten
    error = 0
    @concert.stars.each do |star|
      message = Message.new(send_type: "new_concert", creator_type: "Star", creator_id: star.id, subject_type: "Concert", subject_id: @concert.id, notification_text: "你关注的艺人发布了一个新的演出众筹", title: "新的演出众筹", content: "#{star.name}刚刚发布了一个新的演出众筹，还等什么，快来投票吧！")
      error += 1 if message.send_umeng_message(users_array, none_follower: "演出创建成功，但是因为艺人粉丝数为0，所以消息创建失败") != 'success'
    end
    if error > 0
      flash[:alert] = '推送发送失败'
    else
      flash[:notice] = '推送发送成功'
    end
    render json: {success: true}
  end

  def refresh_map_data
    render partial: "city_voted_data", locals: {concert: @concert, stars: @concert.stars}
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
    @topics = if params[:city_id]
                user_ids = @concert.user_vote_concerts.where(city_id: params[:city_id]).pluck(:user_id)
                @topics.where('creator_type = "User" AND creator_id in (?)', user_ids).page(params[:page]).per(5)
              end

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
  def concert_params
    params.require(:concert).permit(:name, :is_show, :status, :description, :poster, :description_time, :star_ids)
  end

  def get_concert
    @concert = Concert.find(params[:id])
  end
end
