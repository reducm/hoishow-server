class Operation::OrdersController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @orders = Order.all
  end

  def show
    @order = Order.find(params[:id])
  end
  
  def update_express_id
    @order = Order.find(params[:id])
    if @order.update!(express_id: params[:content])
      render json: {success: true}
    end
  end
end
