json.(ticket, :area_id, :show_id, :price, :code, :status)
json.seat_name ticket.seat_name || ''
json.created_at ticket.created_at.to_ms
json.updated_at ticket.updated_at.to_ms
json.area { json.partial!("api/v1/areas/area", {area: ticket.area, show: ticket.show}) }
json.show_name ticket.show.name
