# encoding: utf-8
class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_order, except: [:index]
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    @r_ticket_orders = Order.orders_with_r_tickets

    # 供view过滤
    @status_filter = status_filter
    # {"hoishow"=>0, "bike_ticket"=>1}
    @channel_filter = Order.channels
    @buy_origin_filter = buy_origin_filter
    @show_filter = show_filter

    respond_to do |format|
      format.html
      # json数据组装, 详见app/services/orders_datatable.rb
      format.json { render json: OrdersDatatable.new(view_context) }
    end
  end

  def show
  end

  def update_express_id
    if @order.update!(express_id: params[:content], status: 2)
      render json: {success: true}
    end
  end

  def update_remark_content
    if @order.update!(remark: params[:remark])
      flash[:notice] = "更新备注成功"
    else
      flash[:alert] = "更新备注失败"
    end
    redirect_to operation_order_url(@order)
  end

  def manual_refund
    payment = @order.payments.first
    if payment && payment.refund_order
      @order.update(refund_by: @current_admin.name)
      flash[:notice] = '退款成功'
    else
      flash[:notice] = '退款失败'
    end
    redirect_to operation_orders_url
  end

  def manual_send_sms
    SendSmsWorker.perform_async(@order.user.mobile, "您订购的演出门票已发货，顺丰速运：#{@order.express_id}。可使用客户端查看订单及物流信息。客服电话：4008805380【单车娱乐】")

    flash[:notice] = '短信发送成功'
    redirect_to operation_orders_url
  end

  private
  def get_order
    @order = Order.find params[:id]
  end

  # {"已出票"=>2, "未支付"=>0, ...}
  def status_filter
    hash = {}
    Order.select(:status).distinct.order(:status).each do |order|
      hash[order.tran("status")] = order[:status]
    end
    hash
  end

  # {"ios"=>"ios", "android"=>"android"}
  def buy_origin_filter
    hash = {}
    Order.select(:buy_origin).distinct.each do |order|
      hash[order[:buy_origin]] = order[:buy_origin]
    end
    hash
  end

  # {"Coldplay全球巡回演唱会北京站"=>"Coldplay全球巡回演唱会北京站"}
  def show_filter
    hash = {}
    Order.select(:show_name).distinct.each do |order|
      hash[order[:show_name]] = order[:show_name]
    end
    hash
  end
end
