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
    concert = Concert.find(params[:show][:concert_id])
    if @show.save && concert
      city = City.find(@show.city_id)
      user_ids = UserVoteConcert.where(concert_id: concert.id, city_id: city.id).pluck(:user_id)
      users_array = User.where("id in (?)", user_ids)
      message = Message.new(send_type: "new_show", creator_type: "Concert", creator_id: concert.id, subject_type: "Show", subject_id: @show.id, notification_text: "你有可以优先购票的演唱会", title: "新演唱会购票通知", content: "#{@show.name}众筹成功，将在#{city.name}开演,作为忠粉的你可以优先购票啦！")
      if ( result = message.send_umeng_message(users_array, message, none_follower: "演唱会创建成功，但是因为关注演出的用户数为0，所以消息创建失败")) != "success"
        flash[:alert] = result
      end
      redirect_to action: :index
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

  def update_area_data
    relation = ShowAreaRelation.where(show_id: params[:id], area_id: params[:area_id]).first_or_create
    relation.update(price: params[:price], seats_count: params[:seats_count])

    render partial: "area_table", locals:{show: @show, stadium: @show.stadium}
  end

  def update_status
    @show = Show.find(params[:id])
    if @show.update(status: params[:status].to_i)
      users_array = @show.show_followers
      message = Message.new(send_type: "all_users_buy", creator_type: "Show", creator_id: @show.id, subject_type: "Show", subject_id: @show.id, notification_text: "#{@show.name}已经开放购票啦～", title: "演唱会开放购买通知", content: "你关注的#{@show.name}已经开放购票了，快叫上小伙伴们一起买买买吧！")
      if ( result = message.send_umeng_message(users_array, message, none_follower: "演出状态更新成功，但是因为关注演出的用户数为0，所以消息创建失败")) != "success"
        flash[:alert] = result
      end
    end
    redirect_to operation_show_url(@show)
  end

  protected
  def show_params
    params.require(:show).permit(:name, :show_time, :is_display, :poster, :city_id, :stadium_id, :description, :concert_id)
  end

  def get_show
    @show = Show.find(params[:id])
  end
end
