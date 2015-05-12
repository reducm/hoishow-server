json.(area, :name, :seats_count, :stadium_id)
json.created_at area.created_at.to_ms
json.updated_at area.updated_at.to_ms
area_stadium = area.stadium
area.stadium ? ( json.stadium { json.partial!("api/v1/stadiums/stadium", {stadium: area.stadium}) } ) : (json.stadium nil)
