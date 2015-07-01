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
    raise RuntimeError, 'SeatSelectionLogic 缺少 user 或者 app_platform' if @user.nil? || @app_platform.nil?
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
        # create_order and callback
        @order = user.orders.init_from_show(show)
        # 设置 tickets 信息,考虑放到 state_machine init 的 callback
        @order.set_tickets_and_price(relations)
        @order.update(buy_origin: app_platform)
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
      @order = user.orders.init_from_show(show)
      @order.save
      # 设置座位信息, 考虑放到 state_machine init 的 callback
      areas = JSON.parse options[:areas]
      areas.each do |area_array|
        area = show.areas.find_by_id(area_array['area_id'])
        Seat.transaction do
          area_array['seats'].each do |seat_array|
            seat = area.seats.find_by_id(seat_array['id'])
            seat.with_lock do
              seat.update(status: :locked, order_id: @order.id)
              order.set_tickets_info(seat)
              order.update(amount: order.tickets.sum(:price), buy_origin: app_platform)
            end
          end
        end
      end

      @response = 0
    else
      @response, @error_msg = 3, "不能提交空订单"
    end
  end
end
