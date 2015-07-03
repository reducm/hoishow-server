class SeatSelectionLogic
  # toDo:
  # 一些错误处理和日志
  # response 结果可以优化
  attr_reader :show, :options, :response, :user, :app_platform, :error_msg, :order

  def initialize(show, options={})
    # 其他参数以 options 传进来是考虑到扩展问题
    @show = show
    @options = options
    @user = options[:user]
    @app_platform = options[:app_platform] # 这个可能要改成 channel
    # raise RuntimeError, 'SeatSelectionLogic 缺少 user 或者 app_platform' if @user.nil? || @app_platform.nil?
  end

  def success?
    # response 返回不同的错误码，可能方便于识别
    response == 0
  end

  def execute
    send "create_order_with_#{show.seat_type}"
  end

  private

  def create_order_with_selected
    # 找出该演唱会区域信息
    relation = ShowAreaRelation.where(show_id: show.id, area_id: options[:area_id]).first

    if show.area_seats_left(relation.area) - options[:quantity].to_i < 0
      @response, @error_msg = 1, "购买票数大于该区剩余票数!"
      return
    end

    relations ||= []
    options[:quantity].to_i.times{relations.push relation}

    relation.with_lock do
      if relation.is_sold_out
        @response, @error_msg = 2, "你所买的区域暂时不能买票, 请稍后再试"
      else
        # create_order
        create_order!
        # update order amount
        @order.update_attributes(amount: relations.map{|relation| relation.price}.inject(&:+))
        # create_tickets callback
        @order.create_tickets_by_relations(relations)

        # update relation info
        relation.reload
        if show.area_seats_left(relation.area) == 0
          relation.update_attributes(is_sold_out: true)
        end

        @response = 0
      end
    end
  end

  def create_order_with_selectable
    if options[:areas] && options[:areas].present?
      # create_order and callback
      create_order!
      # 设置座位信息, 考虑放到 state_machine init 的 callback
      areas = JSON.parse options[:areas]
      # create_tickets callback
      @order.create_tickets_by_seats(areas)
      # set amount by tickets prices
      @order.update_attributes(amount: @order.tickets.sum(:price))

      @response = 0
    else
      @response, @error_msg = 3, "不能提交空订单"
    end
  end

  def create_order!
    @order = user.orders.init_from_show(show)
    @order.buy_origin = app_platform
    @order.save!
  end
end
