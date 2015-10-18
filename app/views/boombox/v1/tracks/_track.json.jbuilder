json.(track, :id, :name, :artists, :duration)
json.file track.file_url || ''
