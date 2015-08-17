json.(seat, :id, :show_id, :area_id, :row, :column, :name)
json.price seat.price.to_f

if seat.channels.present? && !seat.channels.include?('bike_ticket')
  json.status 'locked'
else
  json.status seat.status
end
