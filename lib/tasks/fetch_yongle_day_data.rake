namespace :fetcher do
  namespace :yongle do
    desc "Fetch Yongle's day data"
    task :day_data => :environment do
      YongleService::Fetcher.fetch_day_data
    end
  end
end
