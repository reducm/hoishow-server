json.array! @collaborators do |colla|
  json.(colla, :id, :followed_count)
  json.name colla.display_name
  json.cover colla.cover_url || ''
end
