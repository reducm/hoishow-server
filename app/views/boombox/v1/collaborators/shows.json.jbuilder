json.array! @shows do |show|
  json.(show, :id, :name, :showtime, :mode)
  json.location show.location_name
  json.poster show.cover_url || ''
end
