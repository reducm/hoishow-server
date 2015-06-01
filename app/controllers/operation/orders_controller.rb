# encoding: utf-8
class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    @orders = Order.page(params[:page]).order("created_at desc")
    #@r_ticket_orders = Order.orders_with_r_tickets.select { |order| order.show.r_ticket? }
    @r_ticket_orders = Kaminari.paginate_array(Order.orders_with_r_tickets.select { |order| order.show.r_ticket? }).page(params[:page]).per(10)
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
end
