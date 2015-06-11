# encoding: utf-8
class Operation::ShowsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_show, except: [:index, :new, :create, :get_city_stadiums, :search]
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    @shows = Show.page(params[:page]).order("created_at desc")
  end

  def new
    @show = Show.new
    if params[:concert_id]
      @concert = Concert.find(params[:concert_id])
    end
  end

  def search
    params[:page] ||= 1
    star_ids = Star.where("name like ?", "%#{params[:q]}%").map(&:id).compact
    concert_ids = StarConcertRelation.where("star_id in (?)", star_ids).map(&:concert_id).compact
    @shows = Show.where("name like ? or concert_id in (?)", "%#{params[:q]}%", concert_ids).page(params[:page]).order("created_at desc")
    render :index
  end

  def create
    @show = Show.new(show_params)
    concert = Concert.find(params[:show][:concert_id])
    if @show.save! && concert
      city = City.find(@show.city_id)
      user_ids = UserVoteConcert.where(concert_id: concert.id, city_id: city.id).pluck(:user_id)
      users_array = User.where("id in (?)", user_ids)
      message = Message.new(send_type: "new_show", creator_type: "Star", creator_id: concert.stars.first.id, subject_type: "Show", subject_id: @show.id, notification_text: "你有可以优先购票的演唱会", title: "新演唱会购票通知", content: "#{@show.name}众筹成功，将在#{city.name}开演,作为忠粉的你可以优先购票啦！")
      if ( result = message.send_umeng_message(users_array, message, none_follower: "演唱会创建成功，但是因为关注演出的用户数为0，所以消息创建失败")) != "success"
        flash[:alert] = result
      else
        flash[:notice] = "演出创建成功"
      end
      message = Message.new(send_type: "new_show", creator_type: "Star", creator_id: concert.stars.first.id, subject_type: "Show", subject_id: @show.id, notification_text: "你关注的艺人发布新演出咯！", title: "新演唱会通知", content: "你关注的艺人将参与在#{city.name}开演的#{@show.name},快来支持你偶像吧！")
      concert.stars.each {|star| users_array.push(star.followers)}
      if ( result = message.send_umeng_message(users_array.flatten, message, none_follower: "演唱会创建成功，但是因为关注演出的用户数为0，所以消息创建失败")) != "success"
        flash[:alert] = result
      else
        flash[:notice] = "演出创建成功"
      end
      redirect_to operation_shows_url
    else
      flash[:alert] = @show.errors.full_messages
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
      flash[:notice] = "演出修改成功"
      redirect_to operation_shows_url
    else
      flash[:alert] = @show.errors.full_messages
      render :edit
    end
  end

  def get_city_stadiums
    data = City.find(params[:city_id]).stadiums.select(:name, :id, :pic).map {|stadium| {name: stadium.name, id: stadium.id, pic: stadium.pic.url}}
    render json: data
  end

  def new_area
    @show.areas.create(stadium_id: @show.stadium_id, name: params[:area_name])
    render partial: "area_table", locals: {show: @show}
  end

  def update_area_data
    area = @show.areas.find_by_id(params[:area_id])
    area.update(name: params[:area_name])

    relation = @show.show_area_relations.where(area_id: area.id).first_or_create
    relation.update(price: params[:price], seats_count: params[:seats_count])

    render partial: "area_table", locals:{show: @show, stadium: @show.stadium}
  end

  def del_area
    area = @show.areas.find_by_id(params[:area_id])
    if area && area.destroy
      render partial: "area_table", locals: {show: @show}
    end
  end

  def seats_info
    @area = @show.areas.find_by_id(params[:area_id])
    @seats = @area.seats.where(show_id: @show.id)
  end

  def update_seats_info
    @area = @show.areas.find_by_id(params[:area_id])
    @area.update(name: params[:area_name], sort_by: params[:sort_by])
    Seat.transaction do
      @show.seats.where(area_id: @area.id).delete_all
      set_seats(params[:seats_info])
    end
    render json: {success: true}
  end

  def update_mode
    @show = Show.find(params[:id])
    if @show.update(mode: params[:mode].to_i)
      users_array = @show.show_followers
      message = Message.new(send_type: "all_users_buy", creator_type: "Star", creator_id: @show.stars.first.id, subject_type: "Show", subject_id: @show.id, notification_text: "#{@show.name}已经开放购票啦～", title: "演唱会开放购买通知", content: "你关注的#{@show.name}已经开放购票了，快叫上小伙伴们一起来参与吧！")
      if ( result = message.send_umeng_message(users_array, message, none_follower: "演出状态更新成功，但是因为关注演出的用户数为0，所以消息创建失败")) != "success"
        flash[:alert] = result
      end
    end
    redirect_to operation_show_url(@show)
  end

  def toggle_is_top
    if @show.is_top
      @show.update(is_top: false)
    else
      @show.update(is_top: true)
    end
    redirect_to operation_shows_url
  end

  protected
  def show_params
    params.require(:show).permit(:ticket_pic, :description_time, :status, :ticket_type, :name, :show_time, :is_display, :poster, :city_id, :stadium_id, :description, :concert_id, :stadium_map, :seat_type)
  end

  def get_show
    @show = Show.find(params[:id])
  end

  def set_seats(str)
    seats_info = JSON.parse str
    rowId = 1
    seats_info['seats'].each do |row|
      columnId = seats_info['sort_by'] == 'asc' ? 1 : row.select{|s| s['seat_status'] != 'unused'}.size
      row.each do |seat|
        seat = @show.seats.where(area_id: @area.id).create(row: seat['row'], column: seat['column'], status: seat['seat_status'], price: seat['price'])
        if seat.status != 'unused'
          if seat['seat_no']
            seat.update(name: seat['seat_no'])
          else
            seat.update(name: "#{rowId}排#{columnId}座")
          end
          if seats_info['sort_by'] == 'asc'
            columnId += 1
          else
            columnId -= 1
          end
        end
      end
      rowId += 1 unless row.all? {|seat| seat['seat_status'] == 'unused'}
    end
  end
end
