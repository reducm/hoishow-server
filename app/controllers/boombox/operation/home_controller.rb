# encoding: utf-8
class Boombox::Operation::HomeController < Boombox::Operation::ApplicationController
  def index
    # 音乐数量
    @tracks_count = BoomTrack.valid.count
    # 艺人数量
    @collaborators_count = Collaborator.verified.count
    # playlist数量
    @playlists_count = BoomPlaylist.valid_playlists.count
    # 活动数量
    @activities_count = BoomActivity.is_display.count
  end

  def get_graphic_data
    begin_time = params[:time] || "seven_days_from_now"
    a = generate_adapt_array(begin_time)
    adapt_time_array = a[0]
    adapt_date_array = a[1]
    render json: get_data_array(begin_time, adapt_time_array, adapt_date_array)
  end

  private

  def generate_adapt_array(begin_time)
    a = []
    case begin_time
    when "seven_days_from_now"
      a.push([(DateTime.now - 7).to_time..Time.now, "过去7天", "'%m-%d'"])
      x_axis = []
      (0..7).each do |n|
        x_axis << (DateTime.now - n).strftime('%m-%d')
      end
      a.push x_axis.reverse
    when "thirty_days_from_now"
      a.push([(DateTime.now - 30).to_time..Time.now, "过去30天", "'%m-%d'"])
      x_axis = []
      (0..30).each do |n|
        x_axis << (DateTime.now - n).strftime('%m-%d')
      end
      a.push x_axis.reverse
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
