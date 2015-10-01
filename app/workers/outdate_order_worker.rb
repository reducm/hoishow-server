class OutdateOrderWorker
  include Sidekiq::Worker
  def perform(order_id)
    order = Order.find(order_id)
    order.overtime!({handle_ticket_method: 'outdate'})
  end
end
