class RefundOrderWorker
  include Sidekiq::Worker
  def perform(order_id)
    order = Order.find(order_id)
    order.payments.first.refund_order
  end
end
