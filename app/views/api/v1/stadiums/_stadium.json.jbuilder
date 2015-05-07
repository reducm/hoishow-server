json.(stadium, :id, :name, :address, :longitude, :latitude)
json.city { json.partial! "api/v1/cities/city", {city: stadium.city}  }
json.pic stadium.pic.url || ""
