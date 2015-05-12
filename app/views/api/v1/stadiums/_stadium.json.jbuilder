json.(stadium, :id, :name, :address, :longitude, :latitude)
stadium_city = stadium.city
stadium_city ? ( json.city { json.partial!("api/v1/cities/city", {city: stadium_city})  } ) : (json.city nil)
json.pic stadium.pic.url || ""
