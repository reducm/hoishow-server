# 生成订单统一接口，各种渠道的订单生成的业务全部在这里管理
# Hoishow App 端生成订单的调用方法：
# - 选区
#   所需参数 对应的 show, 一个 user, 区域id area_id, 该区域数量 quantity, 渠道 channel
#   options = {user: user, area_id: area_id, quantity: quantity, channel: channel}
# - 选座
#   所需参数 对应的 show, 一个 user, 区域 areas, 该区域数量 quantity, 渠道 channel
#   options = {user: user, areas: areas, quantity: quantity, channel: channel}

# 单车电影端生成订单的调用方法：
# - 选区
#   所需参数 对应的 show, 一个 user_mobile, 区域id area_id, 该区域数量 quantity, 渠道 channel
#   options = {user_mobile: user_mobile, area_id: area_id, quantity: quantity, channel: channel}
# - 选座
#   所需参数 对应的 show, 一个 user, 区域 areas, 该区域数量 quantity, 渠道 channel
#   options = {user_mobile: user_mobile, areas: areas, quantity: quantity, channel: channel}

# 然后统一跑
#   co_logic = CreateOrderLogic.new(@show, options)
#   co_logic.execute
# 判断 co_logic.succeess? 是否为 true, 如果不是 co_logic.error_msg 里面有错误信息
class CreateOrderLogic
  # toDo:
  # 一些错误处理和日志
  # response 结果可以优化
  attr_reader :show, :options, :response, :user, :channel, :error_msg, :order

  def initialize(show, options={})
    # 其他参数以 options 传进来是考虑到扩展问题
    @show = show
    @options = options
    @user = options[:user]
    @channel = options[:channel]
    # raise RuntimeError, 'CreateOrderLogic 缺少 user 或者 channel' if @user.nil? || @channel.nil?
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

    quantity = options[:quantity].to_i

    area_seats_left_result = show.area_seats_left(relation.area) - quantity

    if area_seats_left_result < 0
      @response, @error_msg = 2003, "购买票数大于该区剩余票数!"
      return
    end

    relations ||= []
    quantity.times{relations.push relation}

    relation.with_lock do
      if relation.is_sold_out
        @response, @error_msg = 2, "你所买的区域暂时不能买票, 请稍后再试"
      else
        # create_order
        create_order!
        # update order amount
        @order.update_attributes(amount: relation.price * quantity)
        # create_tickets callback
        @order.create_tickets_by_relations(relations)

        # update relation info
        relation.reload
        if area_seats_left_result == 0
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
    # 按渠道来生成订单
    if [ApiAuth::APP_IOS, ApiAuth::APP_ANDROID].include?(channel)
      @order = user.orders.init_from_show(show)
    elsif ApiAuth::DANCHE_SERVER == channel
      @order = Order.init_from_show(show)
      @order.user_mobile = options[:user_mobile]
      # 看还有那些 user 的参数需要设置
    end

    @order.buy_origin = channel
    @order.save!
  end
end
