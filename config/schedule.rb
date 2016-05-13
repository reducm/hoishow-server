# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever
set :output, "log/cron.log"

# every 5.minutes do
#   rake "orders:check_outdate_orders"
# end

# every 30.minutes do
#   rake "orders:check_refund_orders"
# end

every 1.day do
  rake "shows:check_finished_shows"
  rake "shows:check_hidden_shows"
end

# every 1.day do
#   rake "boom_playlists:get_newest_cover"
#   runner "Event.hide_finished_event"
# end

every '30 1,10,15,20 * * *' do
  rake "fetcher:yongle:day_data"
end

# #viagogo
# every 1.day, :at => '4:30 am' do
#   rake "viagogo:data"
# end
