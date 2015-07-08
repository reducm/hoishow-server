# encoding: utf-8
class Open::V1::OrdersController < Open::V1::ApplicationController
  # before_action :user_auth!
  before_action :mobile_auth!, only: [:show, :create, :unlock_seat, :confirm]
  before_action :show_auth!, only: :create
  before_action :order_auth!, only: [:show, :unlock_seat, :confirm]
  # 订单信息查询
  def show
  end

  def create
    options = params.slice(:area_id, :quantity, :areas, :moive_user_id)
    options[:user_mobile] = order_params[:mobile]
    # 单车电影那边过来的，用 mobile 找到或者创建一个 hoishow 的 user
    options[:user] = User.find_mobile(order_params[:mobile])
    # set channel
    options[:app_platform] = 'moive' # @auth.app_platform
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
    if !@order.pre_pay! || !@order.success_pay!
      @error_code = 3012
      @message = '订单确认失败'
    end
  end

  private
  def order_auth!
    @order = Order.where(out_id: order_params[:out_id], user_mobile: order_params[:mobile]).first
    if @order.nil?
      not_found_respond('找不到该订单')
    end
  end

  def user_auth!
  end

  def order_params
    params.permit(:out_id, :area_id, :quantity, :areas, :mobile, :reason,
      # for 单车电影的参数
      :moive_user_id, :movie_out_id)
  end

  def mobile_auth!
    if verify_phone?(order_params[:mobile]).nil?
      @error_code = 3005
      @message = '手机号不正确'
      respond_to { |f| f.json }
    end
  end
end
