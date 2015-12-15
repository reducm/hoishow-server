namespace :fetch do
  task :fetch_beatport_data => :environment do
    FetchBeatportData::Service.fetch_data
  end
end

namespace :fetch_bp_data do
  #调用方式: rake fetch_bp_data:invoke method=方法名
  task :invoke => :environment do
    FetchBeatportData::Service.send ENV["method"].to_sym
  end
end
