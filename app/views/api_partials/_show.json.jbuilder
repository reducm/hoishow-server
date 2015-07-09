json.(show, :id, :name, :concert_id, :city_id, :stadium_id, :status, :is_top, :ticket_type, :mode, :seat_type)
json.concert_name show.concert.name
json.city_name show.city.name
json.stadium_name show.stadium.name
json.description description_path(subject_id: show.id, subject_type: "Show")
json.description_time show.description_time || ''
json.show_time show.show_time.to_i
json.poster show.poster_url || ''
json.ticket_pic show.ticket_pic_url || ''
json.stadium_map show.stadium_map_url || ''
