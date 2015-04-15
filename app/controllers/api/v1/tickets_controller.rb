class Api::V1::TicketsController < Api::V1::ApplicationController
  def index
    params[:page] ||= 1
    @tickets = Ticket.page(params[:page])
  end 
end
