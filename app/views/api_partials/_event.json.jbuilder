json.(event, :id, :show_id)
json.description_time event.description_time || ''
json.show_time event.show_time.to_i rescue ''
