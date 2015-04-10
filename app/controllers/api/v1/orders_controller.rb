class Api::V1::OrdersController < Api::V1::ApplicationController
  before_action :check_login!
  def index
    params[:page] ||= 1
    @orders = @user.orders.page(params[:page])
  end

  def show
    @order = @user.orders.where(out_id: params[:id]).first
  end
end
