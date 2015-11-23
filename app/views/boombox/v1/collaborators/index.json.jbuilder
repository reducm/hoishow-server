json.array! @collaborators do |colla|
  json.(colla, :id, :followed_count)
  json.name colla.nickname || colla.name
  json.cover colla.cover_url || ''
end
