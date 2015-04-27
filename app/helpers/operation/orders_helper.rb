module Operation::OrdersHelper
  def user_name(user)
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
end
