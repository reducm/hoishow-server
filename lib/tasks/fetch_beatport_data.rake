namespace :fetch do
  task :fetch_beatport_data => :environment do
    FetchBeatportData::Service.fetch_data
  end
end
