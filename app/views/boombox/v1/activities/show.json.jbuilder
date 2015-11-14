json.(@activity, :id, :name, :showtime, :mode)
json.poster @activity.cover_url || ''
json.description

location = @activity.boom_location

json.location do
  json.(location, :name, :longitude, :latitude) rescue nil
end

json.collaborators do
  json.array! @activity.collaborators do |colla|
    json.(colla, :id, :name)
    json.cover colla.cover_url || ''
  end
end

json.tracks do
  json.array! @activity.tracks, partial: 'boombox/v1/tracks/track', as: :track
end
