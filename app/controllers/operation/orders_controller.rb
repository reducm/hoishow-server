# encoding: utf-8
class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    @orders = Order.page(params[:page]).order("created_at desc")
    @r_ticket_orders = Kaminari.paginate_array(Order.orders_with_r_tickets.select { |order| order.show.r_ticket? }).page(params[:page]).per(10)
    respond_to do |format|
      format.html
      format.csv { send_data @orders.to_csv(encoding: "UTF-8") }
      format.xls
    end
  end

  def search
    params[:page] ||= 1
    ids = User.where("nickname like ? or mobile like ?", "%#{params[:q]}%", "%#{params[:q]}%").map(&:id).compact
    @orders = Order.where("show_name like ? or user_id in (?)", "%#{params[:q]}%", ids).page(params[:page]).order("created_at desc")
    @r_ticket_orders = Kaminari.paginate_array(Order.orders_with_r_tickets.select { |order| order.show.r_ticket? }).page(params[:page]).per(10)
    render :index
  end

  def search_express
    params[:page] ||= 1
    @orders = Order.page(params[:page]).order("created_at desc")
    @r_ticket_orders = Kaminari.paginate_array(Order.where("user_name like ? or user_mobile like ? or user_address like ?", "%#{params[:q]}%","%#{params[:q]}%", "%#{params[:q]}%").orders_with_r_tickets.select { |order| order.show.r_ticket? }).page(params[:page]).per(10)
    render :index
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
