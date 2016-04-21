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
    if @order.update(express_id: params[:content])
      @order.query_express
      render json: {success: true}
    end
  end

  def manual_send_msg
    @order.update(sms_has_been_sent: true) unless @order.sms_has_been_sent
    @order.notify_delivery

    flash[:notice] = '短信发送成功'
    redirect_to operation_orders_url
  end

  def update_order_data
    options = {}
    if params["order"]["remark"].present?
      options.merge!({remark: params["order"]["remark"]})
    end
    if params["order"]["ticket_pic"].present?
      options.merge!({ticket_pic: params["order"]["ticket_pic"]})
    end
    if params["order"]["buy_price"].present?
      options.merge!({buy_price: params["order"]["buy_price"]})
    end
    @order.update(options)
    flash[:notice] = '更新资料成功'
    redirect_to operation_order_url(@order)
  end

  def update_buy_price
    if params["buy_price"] && @order.update(buy_price: params["buy_price"])
      respond_to do |format|
        format.json { render json: { message: '更新成功！', status: 200, buy_price: @order.buy_price } }
      end
    else
      respond_to do |format|
        format.json { render json: { message: '更新失败！', status: 403 } }
      end
    end
  end

  def finish_order
    if @order.paid?
      #变更状态
      @order.success_pay!
    end
    #发短信
    text = "亲爱的单车用户，您购买的电子门票已经发送至您的邮箱，请注意查收。如有疑问，请致电客服 400-880-5380【单车娱乐】"
    SendSmsWorker.perform_async(@order.user.mobile, text)
    #发邮件
    ViagogoMailer.notify_user_ticket_pic(@order).deliver_now

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
