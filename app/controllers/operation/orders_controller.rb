# encoding: utf-8
class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_order, except: [:index]
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    #搜索
    if params[:q]
      ids = User.where("nickname like ? or mobile like ?", "%#{params[:q]}%", "%#{params[:q]}%").map(&:id).compact
      @orders = Order.where("show_name like ? or user_id in (?)", "%#{params[:q]}%", ids).order("created_at desc")
      @r_ticket_orders = Order.orders_with_r_tickets
    elsif params[:q_express]
      @orders = Order.order("created_at desc")
      @r_ticket_orders = Order.where("user_name like ? or user_mobile like ? or user_address like ?", "%#{params[:q_express]}%","%#{params[:q_express]}%", "%#{params[:q_express]}%").orders_with_r_tickets
    else
      @orders = Order.order("created_at desc")
      @r_ticket_orders = Order.orders_with_r_tickets
    end
    #下拉框筛选
    case params[:order_status_select]
    when "pending"
      @orders = @orders.where(status: 0)
    when "paid"
      @orders = @orders.where(status: 1)
    when "success"
      @orders = @orders.where(status: 2)
    when "refund"
      @orders = @orders.where(status: 3)
    when "outdate"
      @orders = @orders.where(status: 4)
    end
    #导出时不分页
    unless params[:page] == "0"
      params[:page] ||= 1
      @orders = @orders.page(params[:page])
    end
    @r_ticket_orders = @r_ticket_orders.page(params[:r_ticket_orders_page])
    #导出
    filename = Time.now.strfcn_time + '订单列表'
    respond_to do |format|
      format.html { render :index }
      format.csv { send_data @orders.to_csv, filename: filename + '.csv'}
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xls\""}
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
end
