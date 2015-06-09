json.(city, :id, :pinyin, :name, :code)
json.is_show city.id.in?(concert.shows.map(&:city_id))
