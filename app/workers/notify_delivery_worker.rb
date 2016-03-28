class NotifyDeliveryWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, dead: false

  def perform(order_id)
    url = "#{BikeSetting['notify_delivery_url']}?id=#{order_id}"

    RestClient::Request.execute(
        :method => :get,
        :url => url,
        :timeout => 10,
        :open_timeout => 10
    )
  end
end
