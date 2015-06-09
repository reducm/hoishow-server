# encoding: utf-8
class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    #搜索
    if params[:q]
      ids = User.where("nickname like ? or mobile like ?", "%#{params[:q]}%", "%#{params[:q]}%").map(&:id).compact
      @orders = Order.where("show_name like ? or user_id in (?)", "%#{params[:q]}%", ids).page(params[:page]).order("created_at desc")
      @r_ticket_orders = Kaminari.paginate_array(Order.orders_with_r_tickets.select { |order| order.show.r_ticket? }).page(params[:page]).per(10)
    elsif params[:q_express_express]
      @orders = Order.page(params[:page]).order("created_at desc")
      @r_ticket_orders = Kaminari.paginate_array(Order.where("user_name like ? or user_mobile like ? or user_address like ?", "%#{params[:q_express]}%","%#{params[:q_express]}%", "%#{params[:q_express]}%").orders_with_r_tickets.select { |order| order.show.r_ticket? }).page(params[:page]).per(10)
    else
      @orders = Order.page(params[:page]).order("created_at desc")
      @r_ticket_orders = Kaminari.paginate_array(Order.orders_with_r_tickets.select { |order| order.show.r_ticket? }).page(params[:page]).per(10)
    end
    #下拉框筛选
    case params[:order_status_select]
    when "pending"
      @orders = @orders.where(status: 0)
      @r_ticket_orders = @r_ticket_orders.where(status: 0)
    when "paid"
      @orders = @orders.where(status: 1)
      @r_ticket_orders = @r_ticket_orders.where(status: 1)
    when "success"
      @orders = @orders.where(status: 2)
      @r_ticket_orders = @r_ticket_orders.where(status: 2)
    when "refund"
      @orders = @orders.where(status: 3)
      @r_ticket_orders = @r_ticket_orders.where(status: 3)
    when "outdate"
      @orders = @orders.where(status: 4)
      @r_ticket_orders = @r_ticket_orders.where(status: 4)
    end
    #导出
    filename = Time.now.strfcn_time + '订单列表'
    respond_to do |format|
      format.html { render :index }
      format.csv { send_data @orders.to_csv, filename: filename + '.csv'}
      format.xls { headers["Content-Disposition"] = "attachment; filename=\"#{filename}.xls\""}
    end
  end

  def show
    @order = Order.find(params[:id])
  end

  def update_express_id
    @order = Order.find(params[:order_id])
    if @order.update!(express_id: params[:content], status: 2)
      @order.set_tickets
      render json: {success: true}
    end
  end

  def update_remark_content
    @order = Order.find(params[:id])
    if @order.update!(remark: params[:remark])
      flash[:notice] = "更新备注成功"
    else
      flash[:alert] = "更新备注失败"
    end
    redirect_to operation_order_url(@order)
  end
end
