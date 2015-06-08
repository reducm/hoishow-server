need_seats_map ||= false

json.(area, :id, :name, :stadium_id)
json.seats_count area.seats_count.to_i
json.created_at area.created_at.to_ms
json.updated_at area.updated_at.to_ms

relations = show.show_area_relations.to_a

if show && relations.any?
  json.price relations.select{|r| r.area_id == area.id}.first.price.to_f
  json.seats_left show.area_seats_left(area)
  json.is_sold_out show.area_is_sold_out(area)
end

if need_seats_map
  json.seats_map "xxx"
end