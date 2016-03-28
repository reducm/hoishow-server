module Operation::OrdersHelper
  def get_username(user)
    if user.nickname
      "#{user.nickname}/#{user.mobile}"
    else
      user.mobile
    end
  end

  def get_areas(order)
    ids = order.tickets.map(&:area_id).compact.uniq
    Area.where("id in (?)", ids)
  end

  def query_express_path(com, code)
    "http://m.kuaidi100.com/index_all.html?type=#{com}&postid=#{code}"
  end
end
