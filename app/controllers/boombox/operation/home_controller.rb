# encoding: utf-8
class Boombox::Operation::HomeController < Boombox::Operation::ApplicationController
  def index
    # 总用户数量
    @total_users_count = User.from_boombox.count
    # 今日新增用户数
    @today_registered_users_count = User.from_boombox.today_registered_users.count
    # 音乐数量
    @tracks_count = BoomTrack.valid.count
    # playlist数量
    @playlists_count = BoomPlaylist.valid_playlists.count
    # 艺人数量
    @collaborators_count = Collaborator.count
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
    users_hash_data = User.from_boombox.where(created_at: adapt_time_array[0]).group("date_format(convert_tz(created_at, '+00:00', '+08:00'), #{adapt_time_array[2]} )").count
    users_array = []
    adapt_date_array.each do |date|
      temp = users_hash_data[date]
      if temp.blank?
        users_array.push(0)
      else
        users_array.push(temp)
      end
    end

    { users_array: users_array, success: true, time_type: adapt_time_array[1], time_array: adapt_date_array }
  end
end
