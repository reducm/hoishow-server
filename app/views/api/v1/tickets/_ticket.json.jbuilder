json.(ticket, :area_id, :show_id, :price, :code, :status)
json.created_at ticket.created_at.to_ms
json.updated_at ticket.updated_at.to_ms
