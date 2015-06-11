need_concert ||= false
need_show ||= false
need_stadium ||= false
need_city ||= false
need_tickets ||= false
@express = @user ? @user.expresses.last : nil

json.(order, :out_id, :amount, :concert_name, :concert_id, :stadium_name, :stadium_id, :show_name, :show_id, :city_name, :city_id, :status)
json.poster order.show.poster_url || ''
json.express_code order.express_id || ''
json.user_address @express.user_address rescue ''
json.province_address @express.province rescue ''
json.city_address @express.city rescue ''
json.district_address @express.district rescue ''
json.user_name order.user_name || @express.user_name rescue ''
json.user_mobile order.user_mobile || @express.user_mobile rescue ''
json.tickets_count order.tickets_count
json.express_id @express.id rescue ''
json.show_time order.show.show_time.to_ms rescue nil
json.ticket_type order.show.ticket_type rescue ''
json.qr_url show_for_qr_scan_api_v1_order_path(order)

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
