class NotifyDeliveryWorker
  include Sidekiq::Worker
  def perform(order_id)
    url = "#{BikeSetting['notify_delivery_url']}?open_trade_no=#{order_id}"
    res = RestClient.get(url)
  end
end
