need_seats_map ||= false

json.(area, :id, :name, :stadium_id)
json.created_at area.created_at.to_ms
json.updated_at area.updated_at.to_ms

# relation = show.show_area_relations.where(area_id: area.id).first
if show && @relation
  json.price @relation.price.to_f
  json.seats_count @relation.seats_count
  json.seats_left @relation.left_seats
  json.is_sold_out @relation.is_sold_out || @relation.channels.present? && !@relation.channels.include?('hoishow')
end

if need_seats_map
  json.seats_map seats_map_path(show_id: show.id, area_id: area.id)
end
