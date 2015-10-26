class NotifyTicketCheckedWorker
  include Sidekiq::Worker
  def perform(order_id)
    url = "#{BikeSetting['notify_url']}?open_trade_no=#{order_id}"

    RestClient::Request.execute(
        :method => :get,
        :url => url,
        :timeout => 10,
        :open_timeout => 10
    )
  end
end
