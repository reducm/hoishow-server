class RefundOrderWorker
  include Sidekiq::Worker
  def perform(order_id)
    order = Order.find_by_id(order_id)
    order.payments.first.refund_order if order
  end
end
