class UpdateViagogoEventWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'update_viagogo_event', retry: 5

  def perform(event_id)
    ViagogoDataToHoishow::Service.update_event_data_with_api(event_id)
  end
end
