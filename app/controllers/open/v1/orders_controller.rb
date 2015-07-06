# encoding: utf-8
class Open::V1::OrdersController < Open::V1::ApplicationController
  # before_action :user_auth!
  before_action :show_auth!, only: :create
  before_action :order_auth!, only: [:show, :unlock_seat, :confirm]
  # 订单信息查询
  def show
  end

  def create
    options = params.slice(:area_id, :quantity, :areas, :user_mobile)
    options[:app_platform] = @auth.app_platform
    ss_logic = SeatSelectionLogic.new(@show, options)
    ss_logic.execute
    if ss_logic.success?
      @order = ss_logic.order
    else
      error_json(ss_logic.error_msg)
    end
  end

  def unlock_seat
    #
  end

  def confirm

  end

  private
  def order_auth!
    @order = Order.where(out_id: params[:out_id], user_mobile: params[:mobile]).first
    if @order.nil?
      not_found_respond('找不到该订单')
    end
  end

  def user_auth!
  end

  def order_params
    params.permit(:area_id, :quantity, :areas, :user_mobile)
  end
end
