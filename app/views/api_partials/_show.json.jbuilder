json.(show, :id, :name, :concert_id, :city_id, :stadium_id, :status, :is_top, :ticket_type, :seat_type, :is_presell)
json.mode show.source
json.concert_name show.concert.name rescue ''
json.city_name show.city.name rescue ''
json.stadium_name show.stadium.name rescue ''
json.description show.description || ''
json.description_time show.description_time || ''
json.poster show.poster_url_for_danche || ''
json.ticket_pic show.ticket_pic_url_for_danche || ''
# 可能有效率问题，先用着
json.stars show.concert.stars.pluck(:name).join(' | ') rescue ''
json.price_range show.get_price_range
json.postage show.r_ticket? ? CommonData.get_value('postage') : 0

if show.events.any?
  json.show_time show.events.last.show_time.to_i
  json.stadium_map show.events.last.stadium_map_url || ''
else
  json.show_time show.show_time.to_i
  json.stadium_map show.stadium_map_url || ''
end
