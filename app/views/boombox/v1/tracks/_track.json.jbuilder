json.(track, :id, :name, :artists, :duration)
json.cover track.cover_url || ''
json.file track.file_url || ''
