# encoding: utf-8
class Operation::HomeController < Operation::ApplicationController
  before_filter :check_login!

  def index
    @concerts = Concert.concerts_without_auto_hide.order('created_at DESC').limit(10)
    @shows = Show.where("status = 0").order("created_at desc").limit(10)
    @topics = Topic.order("created_at desc").limit(10)
    @comments = Comment.order("created_at desc").limit(10)
  end

  def get_graphic_data
    begin_time = params[:time] || "today"
    a = generate_adapt_array(begin_time)
    adapt_time_array = a[0]
    adapt_date_array = a[1]
    render json: get_data_array(begin_time, adapt_time_array, adapt_date_array) 
  end

  private

  def generate_adapt_array(begin_time)
    a = []
    case begin_time
    when "today"
      a.push([Time.now.at_beginning_of_day..Time.now, "本日", "'%H时'"])
      a.push(["00时","01时","02时","03时","04时","05时","06时","07时","08时","09时","10时","11时","12时","13时","14时","15时","16时","17时","18时","19时","20时","21时","22时","23时"])
    when "this_month"
      a.push([Time.now.at_beginning_of_month..Time.now, "本月", "'%d日'"])
      a.push(["01日","02日","03日","04日","05日","06日","07日","08日","09日","10日","11日","12日","13日","14日","15日","16日","17日","18日","19日","20日","21日","22日","23日","24日","25日","26日","27日","28日","29日","30日"])
    when "this_year"
      a.push([Time.now.at_beginning_of_year..Time.now, "本年", "'%m月'"])
      a.push(["01月","02月","03月","04月","05月","06月","07月","08月","09月","10月","11月","12月"])
    end
    a
  end

  def get_data_array(begin_time, adapt_time_array, adapt_date_array)
    users_hash_data = User.where(created_at: adapt_time_array[0]).group("date_format(convert_tz(created_at, '+00:00', '+08:00'), #{adapt_time_array[2]} )").count
    users_array = []
    adapt_date_array.each do |date|
      temp = users_hash_data[date]
      if temp.blank?
        users_array.push(0)
      else
        users_array.push(temp)
      end
    end

    orders_hash_data = Order.where(created_at: adapt_time_array[0], status: Order.statuses[:success]).group("date_format(convert_tz(created_at, '+00:00', '+08:00'), #{adapt_time_array[2]} )").sum(:amount)
    orders_array = []
    adapt_date_array.each do |date|
      temp = orders_hash_data[date]
      if temp.blank?
        orders_array.push(0)
      else
        orders_array.push(temp)
      end
    end

    votes_hash_data = UserVoteConcert.where(created_at: adapt_time_array[0]).group("date_format(convert_tz(created_at, '+00:00', '+08:00'), #{adapt_time_array[2]} )").count
    votes_array = []
    adapt_date_array.each do |date|
      temp = votes_hash_data[date]
      if temp.blank?
        votes_array.push(0)
      else
        votes_array.push(temp)
      end
    end
    { users_array: users_array, orders_array: orders_array, votes_array: votes_array, success: true, time_type: adapt_time_array[1], time_array: adapt_date_array }
  end
end
