need_concert ||= false
need_show ||= false
need_stadium ||= false
need_city ||= false
need_tickets ||= false

json.(order, :out_id, :amount, :concert_name, :concert_id, :stadium_name, :stadium_id, :show_name, :show_id, :city_name, :city_id, :status)
json.poster order.show.poster_url || ''
json.express_id order.express_id || ''
json.user_address order.user_address || ''
json.user_name order.user_name || ''
json.user_mobile order.user_mobile || ''
json.tickets_count order.tickets_count
json.default_address @user.default_address
json.show_time order.show.show_time.to_ms rescue nil
json.ticket_type order.show.ticket_type rescue ''

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

if need_tickets
  json.tickets { json.array! order.tickets, partial: "api/v1/tickets/ticket", as: :ticket }
end

json.created_at order.created_at.to_ms
json.updated_at order.updated_at.to_ms
json.valid_time order.valid_time.to_ms rescue nil
