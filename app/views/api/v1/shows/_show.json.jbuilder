json.(show, :id, :name, :min_price, :max_price, :concert_id, :city_id, :stadium_id) 
json.show_time show.show_time.to_ms
json.poster show.poster.url rescue nil

#TODO is_followed

json.concert { json.partial! "api/v1/concerts/concert", {concert: show.concert}  }
json.city { json.partial! "api/v1/cities/city", {city: show.city}  }
json.stadium { json.partial! "api/v1/stadiums/stadium", {stadium: show.stadium}  }
