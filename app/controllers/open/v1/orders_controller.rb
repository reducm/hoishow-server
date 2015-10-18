# encoding: utf-8
class Open::V1::OrdersController < Open::V1::ApplicationController
  # before_action :user_auth!
  before_action :mobile_auth!, only: [:show, :create, :unlock_seat, :confirm, :cancel_order]
  before_action :show_auth!, only: [:check_inventory, :create]
  before_action :show_status_auth!, only: [:check_inventory, :create]
  before_action :order_auth!, only: [:show, :unlock_seat, :confirm, :cancel_order]
  before_action :replay_create_auth!, only: [:create] # 重复提交同一 bike_out_id 的订单

  def cancel_order
    @response = 1
    begin
      Order.transaction do
        @order.refunds!({handle_ticket_method: 'refund'})
        @response = 0
      end
    rescue => e
      Rails.logger.fatal("*** errors: #{e.message}")
    end
    unless @response == 0
      @message = "订单取消失败"
      @error_code = 3017
    end
  end

  # 订单信息查询
  def show
  end

  def check_inventory
    options = params.slice(:quantity, :area_id, :seats)
    co_logic = CreateOrderLogic.new(@show, options)
    unless co_logic.check_inventory
      @error_code = co_logic.response
      @message = co_logic.error_msg
    end
  end

  def create
    # 演出状态判断
    unless @show.status == 'selling'
      error_respond(2002, @show.status_cn)
    end
    # bike_out_id 表示 单车过来的 out_id, 用于对账
    options = params.slice(:area_id, :quantity, :areas, :bike_out_id, :seats, :buy_origin)

    # 单车电影那边过来的，用 mobile 找到或者创建一个 hoishow 的 user
    user = User.find_or_create_bike_user(order_params[:mobile],
      order_params[:bike_user_id])
    error_respond(3004, '找不到该用户') and return if order_params[:bike_user_id].nil?
    options[:user] = user

    # set way
    options[:way] = @auth.channel

    co_logic = CreateOrderLogic.new(@show, options)
    co_logic.execute

    if co_logic.success?
      @order = co_logic.order
    else
      @error_code = co_logic.response
      @message = co_logic.error_msg
    end
  end

  def unlock_seat
    if ['outdate', 'refund'].exclude?(order_params[:reason])
      @error_code = 3011
      @message = '解锁原因错误'
      return
    end

    if order_params[:reason] == 'outdate'
      result = @order.overtime!
    elsif order_params[:reason] == 'refund'
      result = @order.refunds!
    end

    unless result
      @error_code = 3008
      @message = '订单解锁失败'
    end
  end

  def confirm
    if !@order.pre_pay! || (@order.e_ticket? && !@order.success_pay!)
      @error_code = 3012
      @message = '订单确认失败'
    end

    # 实体票的话，可更新快递信息
    if @order.user_address.nil? && @order.show.r_ticket?
      # user_name 暂时就不关联到 bike_ticket_user
      return if expresses_params.blank?
      express_attr = expresses_params.slice(:user_name, :user_mobile).tap do |p|
        p[:user_address] = expresses_params[:address]
      end
      @order.update_attributes!(express_attr)
    end
  end

  private
  def order_auth!
    @order = Order.where(out_id: order_params[:out_id], channel: Order.channels["#{@auth.channel}"]).first
    if @order.nil?
      error_respond(3006, '订单不存在')
    end
  end

  def user_auth!
  end

  def replay_create_auth!
    channel = @auth.channel
    case channel
    when 'bike_ticket'
      tag = params[:bike_out_id]
    end

    if Order.where(open_trade_no: tag, channel: Order.channels[channel],
      status: Order.statuses[:pending]).exists?
      error_respond(3016, '重复创建订单')
    end
  end

  def order_params
    params.permit(:out_id, :area_id, :quantity, :areas, :mobile, :reason,
      # for 单车电影的参数
      :bike_user_id, :bike_out_id)
  end

  def expresses_params
    params.permit(:user_name, :user_mobile, :address)
  end

  def mobile_auth!
    if verify_phone?(order_params[:mobile]).nil?
      @error_code = 3005
      @message = '手机号不正确'
      respond_to { |f| f.json }
    end
  end

  def show_status_auth!
    # 演出状态判断
    unless @show.status == 'selling'
      error_respond(2002, @show.status_cn)
    end
  end
end
