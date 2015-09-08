# 生成订单统一接口，各种渠道的订单生成的业务全部在这里管理
# Hoishow App 端生成订单的调用方法：
# - 选区
#   所需参数 对应的 show, 一个 user, 区域id area_id, 该区域数量 quantity, 渠道 way
#   options = {user: user, area_id: area_id, quantity: quantity, way: way}
# - 选座
#   所需参数 对应的 show, 一个 user, 区域 areas, 该区域数量 quantity, 渠道 way
#   options = {user: user, areas: areas, quantity: quantity, way: way}

# 单车电影端生成订单的调用方法：
# - 选区
#   所需参数 对应的 show, 一个 user_mobile, 区域id area_id, 该区域数量 quantity, 渠道 way
#   options = {user: user, user_mobile: user_mobile, area_id: area_id, quantity: quantity, way: way}
# - 选座
#   所需参数 对应的 show, 一个 user, 区域 areas, 该区域数量 quantity, 渠道 way
#   options = {user: user, user_mobile: user_mobile, areas: areas, quantity: quantity, way: way}

# 然后统一跑
#   co_logic = CreateOrderLogic.new(@show, options)
#   co_logic.execute
# 判断 co_logic.succeess? 是否为 true, 如果不是 co_logic.error_msg 里面有错误信息
class CreateOrderLogic
  # toDo:
  # 一些错误处理和日志
  # response 结果可以优化
  attr_reader :show, :options, :response, :user, :way, :error_msg, :order, :relation

  def initialize(show, options={})
    # 其他参数以 options 传进来是考虑到扩展问题
    @show = show
    @options = options
    @user = options[:user]
    @way = options[:way]
    # raise RuntimeError, 'CreateOrderLogic 缺少 user 或者 way' if @user.nil? || @way.nil?
  end

  def success?
    # response 返回不同的错误码，可能方便于识别
    response == 0
  end

  def execute
    send "create_order_with_#{show.seat_type}"
  end
  # 可以抽象到选座 logic, 暂时不和下面的 create_order 共用一个判断
  # 因为接口传入的参数有点不一样，一个是 seats 一个是 areas
  def check_inventory
    @response = 0

    if show.selected?
      @relation = ShowAreaRelation.where(show_id: show.id, area_id: options[:area_id]).first

      @quantity = options[:quantity].to_i

      # area_seats_left_result = show.area_seats_left(relation.area) - quantity
      if @relation.is_sold_out
        @response, @error_msg = 3015, "你所买的区域的票已经卖完了！"
      elsif @relation.left_seats < @quantity
        @response, @error_msg = 2003, "购买票数大于该区剩余票数!"
      end

    elsif show.selectable?
      @quantity = if options[:seats].present?
        @seat_ids = JSON.parse(options[:seats])
        @seat_ids.size
      elsif options[:areas] && options[:areas].present?
        @areas = JSON.parse options[:areas]
        @seat_ids = @areas.flat_map { |a| a['seats'].map { |item| item['id'] } }
        @seat_ids.size
      else
        @response, @error_msg = 3014, "缺少参数"
        0
      end

      # 查出是否存在不可用的座位
      if !@seat_ids.blank?
        unavaliable_seats = show.seats.not_avaliable_seats.where(id: @seat_ids).select(:id, :status, :name)

        if !unavaliable_seats.blank?
          seat_msg = unavaliable_seats.pluck(:name).join(',')
          @response, @error_msg = 2004, "#{seat_msg}已被锁定"
        end
      end
    end

    success?
  end

  private

  def create_order_with_selected
    if check_inventory # 库存检查
      # todo: callback style
      # pending_orders = get_pending_orders_ids

      # set order attr
      order_attrs = prepare_order_attrs({tickets_count: @quantity, amount: @relation.price * @quantity, ticket_type: show.ticket_type})
      # create_order and create_tickets callback
      @order = Order.init_and_create_tickets_by_relations(show, order_attrs, @relation)

      # batch_overtime(pending_orders) unless pending_orders.blank?

      @response = 0
    end

  end

  def create_order_with_selectable
    if check_inventory # 库存检查
      # pending_orders = get_pending_orders_ids

      order_attrs = prepare_order_attrs({tickets_count: @quantity, ticket_type: show.ticket_type})
      # 设置座位信息, 考虑放到 state_machine init 的 callback
      # create_order and create_tickets and callback
      begin
        @order = Order.init_and_create_tickets_by_seats(show, order_attrs, @seat_ids)
      rescue ArgumentError => e
        # 先放这里
        Rails.logger.error("create_order_logic error: #{e}")
        @response, @error_msg = 3001, "下单锁座失败"
        return
      end

      # batch_overtime(pending_orders) unless pending_orders.blank?

      @response = 0
    end
  end

  def prepare_order_attrs(attrs={})
    attrs.merge!(user_id: user.id)
    # 按渠道来生成订单

    attrs.tap do |p|
      if ['ios', 'android'].include?(way) # app 端
        p[:channel] = 0
        p[:buy_origin] = way
      elsif 'bike_ticket' == way # 单车电影
        # open_trade_no for 对账
        p[:buy_origin] = options[:buy_origin]
        p[:channel] = 1
        p[:open_trade_no] = options[:bike_out_id]
        p[:user_mobile] = options[:user_mobile]
      end
    end
  end

  # 查询是否存在同一场演出的未支付 orders
  def pending_orders_ids
    # 查出是同一场 show 是否存在未支付 orders, 存在的话则将其 overtime
    @pending_orders_ids ||= user.orders.where(status: Order.statuses[:pending],
      show_id: show.id, channel: Order.channels[way]).pluck(:id)
  end

  def batch_overtime!(pending_orders)
    # delay job
    user.orders.where(id: pending_orders).each do |o|
      o.overtime!
    end
  end
end