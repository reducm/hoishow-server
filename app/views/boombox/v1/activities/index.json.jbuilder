json.array! @activities do |activity|
  json.(activity, :id, :name, :showtime, :mode)
  json.description description_boombox_v1_activity_url(activity)
  json.location_name activity.location_name
  json.poster activity.cover_url || ''
end
