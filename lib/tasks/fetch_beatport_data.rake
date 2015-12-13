namespace :fetch do
  task :fetch_beatport_data => :environment do
    FetchBeatportData::Service.fetch_data
  end

  task :save_beatport_data => :environment do
    FetchBeatportData::Service.save_to_database
  end
end
