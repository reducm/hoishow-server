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

  def get_new_users_data(time = params[:time]) 
    case time
    when 'seven_days_from_now'
      count_new_users(DateTime.now - 7)
    when 'thirty_days_from_now'
      count_new_users(DateTime.now - 30)
    when 'this_year'
      count_new_users(DateTime.now.at_beginning_of_year)
    end
  end

  private

  # 按yyyy-mm-dd格式汇总，参考http://www.w3school.com.cn/sql/func_date_format.asp
  def count_new_users(begin_time)
    new_users = User.where('created_at > ?', begin_time).group("DATE_FORMAT(created_at, '%Y-%m-%d')").count
    (begin_time..DateTime.now).each do |date|
      date = date.strftime '%Y-%m-%d'
      # 没有数据的显示0
      new_users[date] = 0 if new_users[date].blank?
      # 今天显示为“今天”而不是日期
      new_users['今天'] = new_users.delete date if date == DateTime.now.strftime('%Y-%m-%d')
    end
    new_users = new_users.sort.to_h
    resemble_new_users_data(new_users)
  end

  # 组装出mm-dd格式
  def resemble_new_users_data(new_users)
    keys = new_users.keys
    keys.each do |key|
      # "2016-01-19" => ["2016", "01", "19"]
      array = key.split('-')
      # '今天'不做处理
      if array.count == 3
        new_key = array[1] + '-' + array[2]
        new_users[new_key] = new_users.delete key
      end
    end
    # '今天'保持在最后
    new_users['今天'] = new_users.delete '今天'

    render json: { x_axis: new_users.keys, y_axis: new_users.values, success: true }
  end
end
