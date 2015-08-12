# encoding: utf-8
class Operation::TicketsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource only: [:index, :new, :create, :show, :edit, :update]

  def index
    params[:page] ||= 1
    @tickets = Ticket.where(status: 2).page(params[:page]).order("created_at desc")
  end

  def search
    params[:page] ||= 1
    admin_ids = Admin.where("name like ?", "%#{params[:q]}%").map(&:id).compact
    user_ids = User.where("nickname like ? or mobile like ?", "%#{params[:q]}%", "%#{params[:q]}%").map(&:id).compact
    order_ids = Order.where("show_name like ? or user_id in (?)", "%#{params[:q]}%", user_ids).map(&:id).compact
    @tickets = Ticket.where(status: 2).where("admin_id in (?) or order_id in (?)", admin_ids, order_ids).page(params[:page]).order("created_at desc")
    render :index
  end
end
