# encoding: utf-8
class Operation::ShowsController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_show, except: [:index, :new, :create, :get_city_stadiums, :search, :upload]
  before_action :get_orders_filters, only: :show
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
      else
        flash[:alert] = @show.errors.full_messages
      end
      redirect_to edit_operation_show_url(@show)
    else
      concert = Concert.create(name: "(自动生成)", is_show: "auto_hide", status: "finished", start_date: Time.now, end_date: Time.now + 1)
      Star.where('id in (?)', params[:star_ids].split(',')).each {|star| star.hoi_concert(concert)}

      @show.concert_id = concert.id
      if @show.save! && concert
        flash[:notice] = "演出创建成功"
      else
        flash[:alert] = @show.errors.full_messages
      end
      redirect_to edit_operation_show_url(@show)
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
    if concert.auto_hide?
      show_message = Message.new(send_type: 'new_show', creator_type: 'Star', creator_id: @show.first_star.id, subject_type: 'Show', subject_id: @show.id, notification_text: '演出开放售票', title: '演出开放售票', content: "您关注的演出#{@show.name}正式开放售票!")
      if (result = show_message.send_umeng_message(@show.show_followers, none_follower: "演出状态更新成功，但是因为关注演出的用户数为0，所以消息创建失败")) != "success"
        flash[:alert] = result
      else
        flash[:notice] = '推送发送成功'
      end
    else
      user_ids = UserVoteConcert.where(concert_id: concert.id, city_id: @show.city_id).pluck(:user_id)
      users_array = User.where("id in (?)", user_ids)
      star_followers = concert.stars.map{|star| star.followers}.flatten
      concert_message = Message.new(send_type: "new_show", creator_type: "Star", creator_id: concert.stars.first.id, subject_type: "Show", subject_id: @show.id, notification_text: "演出优先购票", title: "演出正式开展", content: "#{@show.name}将在#{@show.city.name}开展,作为忠实粉丝的您可以优先购票了!")
      star_message = Message.new(send_type: "new_show", creator_type: "Star", creator_id: concert.stars.first.id, subject_type: "Show", subject_id: @show.id, notification_text: "您关注的艺人发布了一个新演出", title: "新的演出", content: "你关注的艺人发布了一个新的演出'#{@show.name}'!")
      result_1 = concert_message.send_umeng_message(users_array)
      result_2 = star_message.send_umeng_message(star_followers)

      if result_1 == "success" || result_2 == "success"
        flash[:notice] = "推送发送成功"
      else
        flash[:alert] = "推送发送失败"
      end
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
        @show.seats.where('area_id = ? and order_id is null', area.id).limit(rest_tickets).destroy_all
        new_left_seats = old_left_seats - rest_tickets
        relation.update(price: params[:price], seats_count: params[:seats_count], left_seats: new_left_seats)
      elsif old_seats_count < seats_count #增加了座位
        rest_tickets = seats_count - old_seats_count
        rest_tickets.times { @show.seats.where(area_id: area.id).create(status:Ticket::seat_types[:avaliable], price: params[:price]) }
        relation.update(price: params[:price], seats_count: params[:seats_count], left_seats: rest_tickets + old_left_seats)
      elsif old_seats_count == seats_count #座位不变
        relation.update(price: params[:price])
      end
    end

    render partial: "area_table", locals:{show: @show}
  end

  def del_area
    area = @show.areas.find_by_id(params[:area_id])
    if area && area.destroy
      render partial: "area_table", locals: {show: @show}
    end
  end

  def seats_info
    @area = @show.areas.find_by_id(params[:area_id])

    seats_info = @area.seats_info
    if seats_info
      @seats = seats_info['seats']
      total = seats_info['total'].split('|').map(&:to_i)
      @max_row = total[0]
      @max_col = total[1]
      @sort_by = seats_info['sort_by']
    end

    @channels = ApiAuth.other_channels
  end

  def update_seats_info
    @area = @show.areas.find_by_id(params[:area_id])
    new_seats_info = JSON.parse params[:seats_info]
    si = @area.seats_info || {}
    si.merge! new_seats_info

    if @area.update_attributes seats_info: si
      # 兼容之前的 show_area_relations, 暂时还是先 update 一下
      @show.show_area_relations.where(area_id: @area.id).first.update(
        seats_count: @area.avaliable_and_locked_seats_count,
        left_seats: @area.avaliable_seats_count,
        price: @area.all_price_with_seats.max)

      render json: {success: true}
    else
      render json: {error: true}
    end
  end

  def update_mode
    @show = Show.find(params[:id])
    if @show.update(mode: params[:mode].to_i)
      message = Message.new(send_type: "all_users_buy", creator_type: "Star", creator_id: @show.first_star.id, subject_type: "Show", subject_id: @show.id, notification_text: "演出开放售票", title: "演出开放售票", content: "你关注的演出'#{@show.name}'开放售票!")
      if (result = message.send_umeng_message(@show.show_followers, none_follower: "演出状态更新成功，但是因为关注演出的用户数为0，所以消息创建失败")) != "success"
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

  def upload
    case params[:file_type]
    when 'image'
      image = SimditorImage.create(image: params[:file])
      render json: {file_path: image.image_url}
    when 'video'
      video = Video.create(source: params[:file])
      render json: {file_path: video.source_url}
    else
    end
  end

  protected
  def show_params
    params.require(:show).permit(:ticket_pic, :description_time, :status, :ticket_type, :name, :show_time, :is_display, :poster, :city_id, :stadium_id, :description, :concert_id, :stadium_map, :seat_type)
  end

  def get_show
    @show = Show.find(params[:id])
  end
end
