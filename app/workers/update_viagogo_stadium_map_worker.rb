class UpdateViagogoStadiumMapWorker
  include Sidekiq::Worker
  sidekiq_options queue: 'update_viagogo_stadium_map', retry: 3

  def perform(event_id)
    ViagogoDataToHoishow::Service.update_event_stadium_map_with_api(event_id)
  end
end
