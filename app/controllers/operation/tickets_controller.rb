# encoding: utf-8
class Operation::TicketsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    @tickets = Ticket.where(status: 2).page(params[:page]).order("created_at desc")
  end
end
