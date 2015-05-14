user ||= nil

@followed_shows = user.present? ? user.follow_shows.pluck(:id) : []
@voted_show = user.present? ? user.user_vote_concerts.where(concert_id: show.concert_id, city_id: show.city_id).first : nil

json.(show, :id, :name, :min_price, :max_price, :concert_id, :city_id, :stadium_id, :status)
json.description description_path(subject_id: show.id, subject_type: "Show")
json.show_time show.show_time.to_ms
json.poster show.poster_url || ''
json.is_followed show.id.in?(@followed_shows) ? true : false
json.is_voted @voted_show ? true : false

show_concert = show.concert
show_concert ? ( json.concert { json.partial!("api/v1/concerts/concert", {concert: show.concert}) } ) : (json.concert nil)
show_city = show.city
show_city ? ( json.city { json.partial!("api/v1/cities/city", {city: show.city}) } ) : (json.city nil)
show_stadium = show.stadium
show_stadium ? ( json.stadium { json.partial!("api/v1/stadiums/stadium", {stadium: show.stadium})  } ) : (json.stadium nil)
