namespace :shows do
  task :check_hidden_shows => :environment do
    Show.hidden_shows.each do |show|
      show.update(is_display: false)
    end
  end
end
