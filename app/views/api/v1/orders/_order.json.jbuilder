json.(order, :out_id, :amount, :concert_name, :concert_id, :stadium_name, :stadium_id, :show_name, :show_id, :city_name, :city_id, :status)
order_show = Show.where(id: order.show_id).first
json.show order_show ? ( json.partial! "api/v1/shows/show", { show: order_show } ) : ""
order_concert = Concert.where(id: order.concert_id).first
json.concert order_concert ? ( json.partial! "api/v1/concerts/concert", {concert: order_concert} ) : ""
order_stadium = Stadium.where(id: order.stadium_id).first
json.stadium order_stadium ? ( json.partial! "api/v1/stadiums/stadium", {stadium: order_stadium} ) : ""
order_city = City.where(id: order.city_id).first
json.city order_city ? ( json.partial! "api/v1/cities/city", {city: order_city} ) : ""


json.tickets do
  json.array! order.tickets do |ticket|
    json.partial! "api/v1/tickets/ticket", ticket: ticket
  end
end
json.created_at order.created_at.to_ms
json.updated_at order.updated_at.to_ms
json.valid_time order.valid_time.to_ms
