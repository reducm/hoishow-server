json.array! @activities do |activity|
  json.(activity, :id, :name, :showtime, :mode)
  json.location_name activity.location_name
  json.poster activity.cover_url || ''
end
