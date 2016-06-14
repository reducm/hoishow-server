class OutdateTicketWorker
  include Sidekiq::Worker
  def perform(ticket_id)
    ticket = Ticket.find ticket_id
    ticket.outdate!
  end
end
