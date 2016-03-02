# encoding: utf-8
class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  before_action :get_order, except: [:index]
  before_action :get_orders_filters, only: :index
  before_action :get_express_list, only: :index
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    filename = Time.now.strfcn_time + '订单列表'
    respond_to do |format|
      format.html
      # 订单json数据组装, 详见app/services/orders_datatable.rb
      format.json { render json: OrdersDatatable.new(view_context) }
      format.xls do
        filter_orders
        headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xls\""
      end
    end
  end

  def show
  end

  def set_order_to_success
    if @order.success_pay!
      flash[:notice] = "出票成功"
      redirect_to operation_orders_url 
    end
  end

  def update_express_id
    render json: {success: true} if @order.update!(express_id: params[:content])
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

  def manual_send_msg
    SendSmsWorker.perform_async(@order.user_mobile, "您订购的演出门票已发货，顺丰速运：#{@order.express_id}。可使用客户端查看订单及物流信息。客服电话：4008805380【单车娱乐】")
    NotifyDeliveryWorker.perform_async(@order.open_trade_no) unless Rails.env.test?

    flash[:notice] = '短信发送成功'
    redirect_to operation_orders_url
  end

  def update_ticket_pic
    if params["order"].present? && params["order"]["ticket_pic"].present?
      @order.update(ticket_pic: params["order"]["ticket_pic"])
      flash[:notice] = '上传门票成功'
    else
      flash[:alert] = '上传门票失败'
    end
    redirect_to operation_order_url(@order)
  end

  def notice_user_by_msg
    SendSmsWorker.perform_async(@order.user_mobile, "【单车娱乐】亲爱的单车用户，您购买的电子门票已经发送至您的邮箱，请注意查收。如有疑问，请致电客服 400-880-5380")
    flash[:notice] = '通知用户成功'
    redirect_to operation_order_url(@order)
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

  def filter_orders
    @orders_for_export = Order.order(created_at: :desc)
    # 搜订单号和手机号
    if params[:search].present?
      if params[:search][:value].present?
        @orders_for_export = @orders_for_export.joins(:user).where("orders.out_id like :search or users.mobile like :search", search: "%#{params[:search][:value]}%" )
      end
    end
    # 按支付状态过滤
    if params[:status].present?
      @orders_for_export = @orders_for_export.where("orders.status like :status", status: "%#{params[:status]}%")
    end
    # 按下单来源过滤
    if params[:channel].present?
      @orders_for_export = @orders_for_export.where("orders.channel like :channel", channel: "%#{params[:channel]}%")
    end
    # 按下单平台过滤
    if params[:buy_origin].present?
      @orders_for_export = @orders_for_export.where("orders.buy_origin like :buy_origin", buy_origin: "%#{params[:buy_origin]}%")
    end
    # 按演出过滤
    if params[:show].present?
      @orders_for_export = @orders_for_export.where("orders.show_id like :show", show: "%#{params[:show]}%")
    end
    # 按下单时间称过滤
    if params[:start_date].present? && params[:end_date].present?
      @orders_for_export = @orders_for_export.where("orders.created_at between ? and ?", params[:start_date], params[:end_date])
    end
    @orders_for_export
  end
end
