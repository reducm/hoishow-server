class NotifyTicketCheckedWorker
  include Sidekiq::Worker
  sidekiq_options retry: 5, dead: false

  def perform(order_id)
    url = "#{BikeSetting['notify_url']}?id=#{order_id}"
    Rails.logger.debug "url: #{url}"
    RestClient::Request.execute(
        :method => :get,
        :url => url,
        :timeout => 10,
        :open_timeout => 10
    )
  end
end
