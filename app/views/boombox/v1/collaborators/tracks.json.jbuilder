json.array! @tracks do |track|
  json.(track, :id, :name, :artists, :duration)
  json.file track.file_url || ''
  json.is_liked track.is_liked?(@user)
end
