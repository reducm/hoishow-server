json.(area, :id, :name, :stadium_id)
json.seats_count area.seats_count.to_i
json.show_id show.id
# json.created_at area.created_at.to_ms
# json.updated_at area.updated_at.to_ms
json.seats_map seats_map_path(show_id: show.id, area_id: area.id)

relation = show.show_area_relations.where(area_id: area.id).first

if show && relation
  json.price relation.price.to_f
  json.seats_left show.area_seats_left(area)
  # 没设置 channel
  json.is_sold_out show.area_is_sold_out(area) && (relation.channels.nil? || !relation.channels.include?('bike'))
end

json.seats_info do
  json.array! area.seats, partial: "api_partials/seat", as: :seat
end
