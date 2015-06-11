json.array! @concerts_and_shows_array.each do |obj|
  if obj.is_a?(Concert)
    json.partial!("api/v1/concerts/concert", {concert: obj}) 
  else
    json.partial!("api/v1/shows/show", {show: obj}) 
  end
end
