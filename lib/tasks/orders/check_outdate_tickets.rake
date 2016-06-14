namespace :orders do
  task :check_outdate_tickets => :environment do
    Ticket.outdate_tickets.each do |ticket|
      OutdateTicketWorker.perform_async(ticket.id)
    end
  end
end
