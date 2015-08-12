need_city ||= false

json.(stadium, :id, :name, :address, :longitude, :latitude)

if need_city
  json.city { json.partial!("api/v1/cities/city", {city: stadium.city}) }
end
