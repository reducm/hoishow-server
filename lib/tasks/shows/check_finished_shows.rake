namespace :shows do
  task :check_finished_shows => :environment do
    Show.finished_shows.each do |show|
      FinishedShowWorker.perform_async(show.id)
    end
  end
end
