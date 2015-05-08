class Operation::TicketsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    params[:page] ||= 1
    @tickets = Ticket.page(params[:page])
  end
end
