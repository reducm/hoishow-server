class OutdateOrderWorker
  include Sidekiq::Worker
  def perform(order_id)
    order = Order.find(order_id)
    order.overtime!
  end
end
