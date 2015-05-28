class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @orders = Order.all
    @r_ticket_orders = Order.orders_with_r_tickets.select { |order| order.show.r_ticket? }
  end

  def show
    @order = Order.find(params[:id])
  end
  
  def update_express_id
    @order = Order.find(params[:id])
    if @order.update!(express_id: params[:content], status: 2)
      @order.set_tickets
      render json: {success: true}
    end
  end
end
