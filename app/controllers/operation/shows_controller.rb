# encoding: utf-8
class Operation::ShowsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_show, except: [:index, :new, :create, :get_city_stadiums, :search]
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    params[:page] ||= 1
    @shows = Show.page(params[:page]).order("created_at desc")
  end

  def search
    params[:page] ||= 1
    star_ids = Star.where("name like ?", "%#{params[:q]}%").map(&:id).compact
    concert_ids = StarConcertRelation.where("star_id in (?)", star_ids).map(&:concert_id).compact
    @shows = Show.where("name like ? or concert_id in (?)", "%#{params[:q]}%", concert_ids).page(params[:page]).order("created_at desc")
    render :index
  end

  def new
    @show = Show.new
    if params[:concert_id]
      @concert = Concert.find(params[:concert_id])
    end
  end

  def create
    @show = Show.new(show_params)
    if params[:show][:concert_id].present?
      concert = Concert.find(params[:show][:concert_id])
      if @show.save! && concert
        flash[:notice] = "演出创建成功"
        redirect_to operation_shows_url
      else
        flash[:alert] = @show.errors.full_messages
        redirect_to new_operation_show_url(concert_id: @show.concert_id)
      end
    else
      concert = Concert.create(name: "(自动生成)", is_show: "auto_hide", status: "finished", start_date: Time.now, end_date: Time.now + 1)
      Star.where('id in (?)', params[:star_ids].split(',')).each {|star| star.hoi_concert(concert)}

      @show.concert_id = concert.id
      if @show.save! && concert
        flash[:notice] = "演出创建成功"
        redirect_to operation_shows_url
      else
        flash[:alert] = @show.errors.full_messages
        redirect_to new_operation_show_url(concert_id: @show.concert_id)
      end
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

  def set_area_channels
    relation = @show.show_area_relations.where(area_id: params[:area_id]).first
    relation.channels = params[:ids]
    if relation.save
      render partial: "area_table", locals:{show: @show}
    else
      render json: {success: false}
    end
  end

  def send_create_message
    concert = @show.concert
    city = City.find(@show.city_id)
    user_ids = UserVoteConcert.where(concert_id: concert.id, city_id: city.id).pluck(:user_id)
    users_array = User.where("id in (?)", user_ids)
    star_followers = concert.stars.map{|star| star.followers}.flatten
    concert_message = Message.new(send_type: "new_show", creator_type: "Star", creator_id: concert.stars.first.id, subject_type: "Show", subject_id: @show.id, notification_text: "你有可以优先购票的演唱会", title: "新演唱会购票通知", content: "#{@show.name}众筹成功，将在#{city.name}开演,作为忠粉的你可以优先购票啦！")
    star_message = Message.new(send_type: "new_show", creator_type: "Star", creator_id: concert.stars.first.id, subject_type: "Show", subject_id: @show.id, notification_text: "你关注的艺人发布新演出咯！", title: "新演唱会通知", content: "你关注的艺人将参与在#{city.name}开演的#{@show.name},快来支持你偶像吧！")
    result_1 = concert_message.send_umeng_message(users_array, none_follower: "演唱会创建成功，但是因为关注演出的用户数为0，所以消息创建失败")
    result_2 = star_message.send_umeng_message(star_followers, none_follower: "演唱会创建成功，但是因为关注演出的用户数为0，所以消息创建失败")

    if result_1 == "success" && result_2 == "success"
      flash[:notice] = "推送发送成功"
    else
      flash[:alert] = "推送发送失败"
    end
    redirect_to operation_show_url(@show)
  end

  def get_city_stadiums
    data = City.find(params[:city_id]).stadiums.select(:name, :id, :pic).map{|stadium| {name: stadium.name, id: stadium.id, pic: stadium.pic.url}}
    render json: data
  end

  def new_area
    area = @show.areas.create(stadium_id: @show.stadium_id, name: params[:area_name])
    if area
      @show.show_area_relations.where(area_id: area.id).first.update(price: 0.0, seats_count: 0)
    end
    render partial: "area_table", locals: {show: @show}
  end

  def update_area_data
    if area = @show.areas.find_by_id(params[:area_id])
      area.update(name: params[:area_name])
    end

    if relation = @show.show_area_relations.where(area_id: area.id).first
      old_seats_count = relation.seats_count
      old_left_seats = relation.left_seats
      seats_count = params[:seats_count].to_i

      if old_seats_count > seats_count #减少了座位
        rest_tickets = old_seats_count - seats_count
        @show.seats.where(area_id: area.id).limit(rest_tickets).destroy_all
        new_left_seats = old_left_seats - rest_tickets
        relation.update(price: params[:price], seats_count: params[:seats_count], left_seats: new_left_seats)
      elsif old_seats_count < seats_count #增加了座位
        rest_tickets = seats_count - old_seats_count
        rest_tickets.times { @show.seats.where(area_id: area.id).create(status:Ticket::seat_types[:avaliable], name:"#{@show.stadium.name} - #{area.name} 区", price: params[:price]) }
        relation.update(price: params[:price], seats_count: params[:seats_count], left_seats: rest_tickets + old_left_seats)
      elsif old_seats_count == seats_count #座位不变
        relation.update(price: params[:price], seats_count: params[:seats_count], left_seats: old_left_seats)
      end
    end
    
    render partial: "area_table", locals:{show: @show}
  end

  def del_area
    area = @show.areas.find_by_id(params[:area_id])
    if area && @show.show_area_relations.where(area_id: params[:area_id]).first.destroy && area.destroy
      render partial: "area_table", locals: {show: @show}
    end
  end

  def seats_info
    @area = @show.areas.find_by_id(params[:area_id])
    @seats = @area.seats.where(show_id: @show.id)
    @channels = ApiAuth.other_channels
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
      if ( result = message.send_umeng_message(users_array, none_follower: "演出状态更新成功，但是因为关注演出的用户数为0，所以消息创建失败")) != "success"
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

  def add_star
    @concert = @show.concert
    star = Star.find_by_id([params[:star_id]])
    if star
      star.hoi_concert(@concert)
      render json: {success: true}
    else
      render json: {error: true}
    end
  end

  def del_star
    @concert = @show.concert
    relation = @concert.star_concert_relations.where(star_id: params[:star_id]).first
    if relation
      relation.destroy
      render json: {success: true}
    else
      render json: {error: true}
    end
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
      row.each do |s|
        @seat = @show.seats.where(area_id: @area.id).create(row: s['row'], column: s['column'], status: s['seat_status'], channels: s['channel_ids'])
        if @seat.status != 'unused'
          if s['seat_no'].blank?
            @seat.update(name: "#{rowId}排#{columnId}座", price: s['price'])
          else
            @seat.update(name: s['seat_no'], price: s['price'])
          end
          if seats_info['sort_by'] == 'asc'
            columnId += 1
          else
            columnId -= 1
          end
        end
      end
      rowId += 1 unless row.all? {|s| s['seat_status'] == 'unused'}
    end
  end
end
