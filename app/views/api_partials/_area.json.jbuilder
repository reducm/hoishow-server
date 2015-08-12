json.(area, :id, :name, :stadium_id)
json.show_id show.id
# json.created_at area.created_at.to_ms
# json.updated_at area.updated_at.to_ms
json.seats_map seats_map_path(show_id: show.id, area_id: area.id)

relation = show.show_area_relations.where(area_id: area.id).first

if show && relation
  json.seats_count relation.seats_count.to_i
  json.price relation.price.to_f
  json.seats_left relation.left_seats
  # 没设置channel，则对所有渠道皆可售
  json.is_sold_out relation.is_sold_out || relation.channels.present? && !relation.channels.include?('bike_ticket')

  json.seats_info do
    json.array! show.seats.where(area_id: area.id), partial: "api_partials/seat", as: :seat
  end
end


