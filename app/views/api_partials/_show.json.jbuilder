json.(show, :id, :name, :concert_id, :city_id, :stadium_id, :status, :is_top, :ticket_type, :mode, :seat_type)
json.concert_name show.concert.name
json.city_name show.city.name rescue ''
json.stadium_name show.stadium.name rescue ''
json.description show.description || ''
json.description_time show.description_time || ''
json.show_time show.events.first.show_time.to_i
json.poster show.poster_url || ''
json.ticket_pic show.ticket_pic_url || ''
json.stadium_map show.stadium_map_url || ''
# 可能有效率问题，先用着
json.stars show.concert.stars.pluck(:name).join(' | ')
json.price_range show.get_price_range
json.postage show.r_ticket? ? CommonData.get_value('postage') : 0
