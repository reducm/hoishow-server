json.(show, :id, :name) 
json.show_time show.show_time.to_ms
json.poster show.poster.url rescue nil

json.concert { json.partial! "api/v1/concerts/concert", {concert: show.concert}  }
json.city { json.partial! "api/v1/cities/city", {city: show.city}  }
json.stadium { json.partial! "api/v1/stadiums/stadium", {stadium: show.stadium}  }