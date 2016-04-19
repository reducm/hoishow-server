class UpdateViagogoShowWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'update_viagogo_show', retry: 5

  def perform(show_id)
    ViagogoDataToHoishow::Service.update_event_data_with_api(show_id)
  end
end
