json.(@activity, :id, :name, :showtime, :mode)
json.showtime @activity.showtime || ''
json.poster @activity.cover_url || ''
json.description description_boombox_v1_activity_url(@activity)

location = @activity.boom_location

if location
  json.location do
    json.(location, :name, :longitude, :latitude)
  end
else
  json.location nil
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
