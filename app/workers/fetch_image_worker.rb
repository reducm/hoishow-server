class FetchImageWorker
  include Sidekiq::Worker
  include YongleService::Fetcher
  sidekiq_options queue: 'fetch_image', retry: 5

  def perform(show_id, url, image_desc)
    YongleService::Fetcher.fetch_image(show_id, url, image_desc)
  end
end
