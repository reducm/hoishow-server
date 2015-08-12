namespace :orders do
  task :check_outdate_orders => :environment do
    Order.pending_outdate_orders.each do |order|
      OutdateOrderWorker.perform_async(order.id)
    end
  end
end
