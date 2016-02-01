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

  def get_users_data(time = params[:time]) 
    case time
    when 'seven_days_from_now'
      new_users = count_new_users(DateTime.now - 7)
      users = count_users(DateTime.now - 7)
      render_users_data(new_users, users)
    when 'thirty_days_from_now'
      new_users = count_new_users(DateTime.now - 30)
      users = count_users(DateTime.now - 30)
      render_users_data(new_users, users)
    when 'this_year'
      new_users = count_new_users(DateTime.now.at_beginning_of_year)
      users = count_users(DateTime.now.at_beginning_of_year)
      render_users_data(new_users, users)
    when 'all'
      count_users_by_year
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
    resemble_users_data(new_users)
  end

  def count_users(begin_time)
    users = {}
    (begin_time..DateTime.now).each do |date|
      count = User.where('created_at <= ?', date).count
      date = date.strftime '%Y-%m-%d'
      users[date] = count
      # 没有数据的显示0
      users[date] = 0 if users[date].blank?
      # 今天显示为“今天”而不是日期
      users['今天'] = users.delete date if date == DateTime.now.strftime('%Y-%m-%d')
    end
    users = users.sort.to_h
    resemble_users_data(users)
  end

  # 组装出mm-dd格式
  def resemble_users_data(users)
    keys = users.keys
    keys.each do |key|
      # "2016-01-19" => ["2016", "01", "19"]
      array = key.split('-')
      # '今天'不做处理
      if array.count == 3
        new_key = array[1] + '-' + array[2]
        users[new_key] = users.delete key
      end
    end
    # '今天'保持在最后
    users['今天'] = users.delete '今天'

    return users
  end

  def render_users_data(new_users, users)
    y_axis = {}
    y_axis['NEW'] = new_users.values
    y_axis['ALL'] = users.values
    render json: { x_axis: new_users.keys, y_axis: y_axis, success: true }
  end

  # 年度
  def count_users_by_year
    users = {}
    users_count = 0
    new_users = User.group("DATE_FORMAT(created_at, '%Y')").count
    start_year = User.order(:created_at).pluck("DATE_FORMAT(created_at, '%Y')").first
    this_year = Time.now.strftime '%Y'

    (start_year..this_year).each do |year|
      # 用年度新增用户数累加，计算出总用户数
      users_count = users_count + new_users[year]
      users[year] = users_count
      new_users['今年'] = new_users.delete year if year == this_year
      users['今年'] = users.delete year if year == this_year
    end
    new_users = new_users.sort.to_h
    users = users.sort.to_h

    render_users_data(new_users, users)
  end
end
