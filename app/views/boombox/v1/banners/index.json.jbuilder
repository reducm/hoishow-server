json.array! @banners do |banner|
  json.(banner, :id, :subject_type, :subject_id)
  json.poster banner.poster_url || ''
end
