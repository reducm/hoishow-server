class OrdersDatatable
  delegate :params, :link_to, to: :@view

  def initialize(view)
    @view = view
  end

# dataTable需要的参数 
  def as_json(options = {})
    {
      draw: params[:draw].to_i, 
      recordsTotal: Order.count,
      recordsFiltered: orders.size,
      data: data
    }
  end

private

  def data
    if params[:orders_all_page] == '1'
      # 需要导出时取全部order
      o = orders
    else
      # 浏览时取分页order
      o = orders_per_page
    end
    o.map do |order|
      user = order.user
      [
        order.out_id,
        link_to(order.show_name, "/operation/shows/#{order.show.id}"),
        order.buy_origin,
        order.channel,
        order.show.try(:ticket_type_cn),
        order.created_at_format,
        order.generate_ticket_at_format,
        order.tickets_count,
        order.amount,
        link_to(order.get_username(user), "/operation/users/#{user.id}"),
        order.status_cn,
        refund_link(order), 
        link_to("查看详情", "/operation/orders/#{order.id}")
      ]
    end
  end

  def refund_link(order)
    if order.need_refund?
      link_to('退款', "/operation/orders/#{order.id}/manual_refund", method: :post)
    else
      ""
    end
  end

  def orders
    @orders ||= fetch_orders
  end

  def orders_per_page
    @orders_per_page ||= Kaminari.paginate_array(orders.to_a).page(page).per(per_page)
  end

  def fetch_orders
    orders = Order.order(created_at: :desc)
    # 搜订单号和手机号
    if params[:search].present?
      if params[:search][:value].present?
        orders = orders.joins(:user).where("orders.out_id like :search or users.mobile like :search", search: "%#{params[:search][:value]}%" )
      end
    end
    # 按支付状态过滤
    if params[:status].present?
      orders = orders.where("orders.status like :status", status: "%#{params[:status]}%")
    end
    # 按下单来源过滤
    if params[:channel].present?
      orders = orders.where("orders.channel like :channel", channel: "%#{params[:channel]}%")
    end
    # 按下单平台过滤
    if params[:buy_origin].present?
      orders = orders.where("orders.buy_origin like :buy_origin", buy_origin: "%#{params[:buy_origin]}%")
    end
    # 按演出过滤
    if params[:show].present?
      orders = orders.where("orders.show_id like :show", show: "%#{params[:show]}%")
    end
    # 按下单时间称过滤
    if params[:start_date].present? && params[:end_date].present?
      orders = orders.where("orders.created_at between ? and ?", params[:start_date], params[:end_date])
    end
    orders
  end

  def page
    params[:start].to_i/per_page + 1
  end

  def per_page
    params[:length].to_i > 0 ? params[:length].to_i : 10
  end
end
