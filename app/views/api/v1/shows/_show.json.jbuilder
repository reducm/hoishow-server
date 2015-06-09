need_concert ||= false
need_topics ||= false
need_stars ||= false
need_stadium ||= false
need_city ||= false
need_areas  ||= false
@user ||= nil

@followed_shows = @user.present? ? @user.follow_shows.pluck(:id) : []
@voted_show = @user.present? ? @user.user_vote_concerts.where(concert_id: show.concert_id, city_id: show.city_id).first : nil

json.(show, :id, :name, :concert_id, :city_id, :stadium_id, :status, :is_top, :ticket_type, :mode, :seat_type)
json.concert_name show.concert.name
json.city_name show.city.name
json.stadium_name show.stadium.name
json.description description_path(subject_id: show.id, subject_type: "Show")
json.show_time show.show_time.to_ms
json.poster show.poster_url || ''
json.stadium_map show.stadium_map_url || ''
json.is_followed show.id.in?(@followed_shows)
json.is_voted @voted_show
json.voters_count ( UserVoteConcert.where(concert_id: show.concert_id, city_id: show.city_id).count + show.get_show_base_number)
json.sharing_page 'http://www.dan-che.com'

if need_concert
  json.concert { json.partial!("api/v1/concerts/concert", {concert: show.concert}) }
end

if need_stadium
  json.stadium { json.partial!("api/v1/stadiums/stadium", {stadium: show.stadium}) }
end

if need_city
  json.city { json.partial!("api/v1/cities/city", {city: show.city}) }
end

if need_topics
  json.topics{ json.array! show.topics, partial: "api/v1/topics/topic", as: :topic }
end

if need_stars
  json.stars { json.array! show.stars, partial: "api/v1/stars/star", as: :star}
end

if need_areas
  json.areas { json.array! show.areas, partial: "api/v1/areas/area", as: :area, show: show, need_seats_map: true}
end
