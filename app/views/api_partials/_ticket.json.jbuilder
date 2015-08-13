json.(ticket, :id, :price, :code, :status)
json.seat_name ticket.seat_name || ''
json.area_name ticket.area.name || ''
