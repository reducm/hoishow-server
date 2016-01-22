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

  def count_new_users(begin_time)
    new_users = User.where('created_at > ?', begin_time).group("DATE_FORMAT(created_at, '%m-%d')").count
    (begin_time..DateTime.now).each do |date|
      date = date.strftime('%m-%d')
      # 没有数据的显示0
      if new_users[date].blank?
        new_users[date] = 0
        # 今天显示为“今天”而不是日期
        if date == DateTime.now.strftime('%m-%d')
          new_users['今天'] = new_users.delete date
        end
      end
    end
    new_users = new_users.sort.to_h

    render json: { x_axis: new_users.keys, y_axis: new_users.values, success: true }
  end
end
