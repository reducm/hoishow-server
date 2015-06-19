module Operation::HomeHelper
  def get_users_data
    a = []
    a.push(User.today_registered_users.count)
    time_now = Time.now
    6.times {|n| a.push(User.where("created_at < ? and created_at > ?", (time_now - n.days).at_beginning_of_day, (time_now - (n+1).days).at_beginning_of_day ).count)}
    a.reverse
  end
  def get_orders_data
    a = []
    a.push(Order.today_success_orders.sum(:amount).to_f)
    time_now = Time.now
    6.times {|n| a.push(Order.where("created_at < ? and created_at > ? and status = ?", (time_now - n.days).at_beginning_of_day, (time_now - (n+1).days).at_beginning_of_day, Order.statuses[:success] ).sum(:amount).to_f)}
    a.reverse
  end
  def get_votes_data
    a = []
    a.push(UserVoteConcert.today_votes.count)
    time_now = Time.now
    6.times {|n| a.push(UserVoteConcert.where("created_at < ? and created_at > ?", (time_now - n.days).at_beginning_of_day, (time_now - (n+1).days).at_beginning_of_day ).count)}
    a.reverse
  end
end
