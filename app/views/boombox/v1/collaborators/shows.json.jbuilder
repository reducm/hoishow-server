json.array! @shows do |show|
  json.(show, :id, :name, :showtime, :mode)
  json.location_name show.location_name
  json.poster show.cover_url || ''
end
