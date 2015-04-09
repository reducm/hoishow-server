json.(order, :out_id, :amount, :concert_name, :concert_id, :stadium_id, :stadium_name, :show_name, :show_id, :city_name, :city_id, :status)
json.tickets do
  json.array! order.tickets do |ticket|
    json.partial! "api/v1/tickets/ticket", ticket: ticket
  end
end
json.created_at order.created_at.to_ms
json.updated_at order.updated_at.to_ms
json.valid_time order.valid_time.to_ms
