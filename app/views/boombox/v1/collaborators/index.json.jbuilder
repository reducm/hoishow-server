json.array! @collaborators do |colla|
  json.(colla, :id, :name, :followed_count)
  json.cover colla.cover_url || ''
end
