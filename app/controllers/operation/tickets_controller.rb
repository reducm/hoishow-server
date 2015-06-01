# encoding: utf-8
class Operation::TicketsController < Operation::ApplicationController
  before_filter :check_login!
  load_and_authorize_resource

  def index
    @tickets = Ticket.where(status: 2)
  end
end
