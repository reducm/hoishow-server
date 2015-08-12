namespace :orders do
  task :check_refund_orders => :environment do
    Order.paid_refund_orders.each do |order|
      RefundOrderWorker.perform_async(order.id)
    end
  end
end
