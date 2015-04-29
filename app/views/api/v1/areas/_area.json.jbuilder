json.(area, :name, :seats_count, :stadium_id)
json.created_at area.created_at.to_ms
json.updated_at area.updated_at.to_ms
json.stadium { json.partial! "api/v1/stadiums/stadium", {stadium: area.stadium}  }
