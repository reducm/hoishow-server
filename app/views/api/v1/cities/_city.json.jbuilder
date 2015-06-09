need_concert ||= false

json.(city, :id, :pinyin, :name, :code)

if need_concert
  json.is_show city.id.in?(concert.shows.map(&:city_id))
end
