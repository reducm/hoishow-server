# encoding: utf-8
class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_order, except: [:index]
  before_action :get_orders_filters, only: :index
  before_action :get_express_list, only: :index
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    respond_to do |format|
      format.html
      # 订单json数据组装, 详见app/services/orders_datatable.rb
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

  # 快递单
  def get_express_list
    r_ticket_orders = Order.orders_with_r_tickets
    if params[:q_express].present?
      r_ticket_orders = Order.where("out_id like ? or user_name like ? or user_mobile like ? or user_address like ?", "%#{params[:q_express]}%", "%#{params[:q_express]}%", "%#{params[:q_express]}%", "%#{params[:q_express]}%").order("created_at desc")
    end
    r_ticket_orders = r_ticket_orders.page(params[:r_ticket_orders_page])
    @r_ticket_orders = r_ticket_orders
  end
end
