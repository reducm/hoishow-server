json.array! @tracks do |track|
  json.(track, :id, :name, :artists, :duration)
  json.file track.file_url || ''
end
