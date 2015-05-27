need_concert ||= false
need_show ||= false
need_stadium ||= false
need_city ||= false

json.(order, :express_id, :user_address, :user_mobile, :user_name, :out_id, :amount, :concert_name, :concert_id, :stadium_name, :stadium_id, :show_name, :show_id, :city_name, :city_id, :status)

if need_show
  json.show {json.partial!("api/v1/shows/show", {show: order.show})}
end

if need_concert
  json.concert { json.partial!("api/v1/concerts/concert", {concert: order.concert}) }
end

if need_stadium
  json.stadium { json.partial!("api/v1/stadiums/stadium", {stadium: order.stadium}) }
end

if need_city
  json.city {json.partial!("api/v1/cities/city", {city: order.city})}
end

json.tickets { json.array! order.tickets, partial: "api/v1/tickets/ticket", as: :ticket }

json.created_at order.created_at.to_ms
json.updated_at order.updated_at.to_ms
json.valid_time order.valid_time.to_ms
