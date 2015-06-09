need_stars ||= false
need_topics||= false
need_shows ||= false
@user ||= nil

@followed_concerts = @user.present? ? @user.follow_concerts.pluck(:id) : []
@voted_concert = @user.present? ? @user.user_vote_concerts.where(concert_id: concert.id).first : nil

json.(concert, :id, :name, :status, :is_top, :followers_count, :shows_count)

json.description description_path(subject_id: concert.id, subject_type: "Concert")
json.start_date concert.start_date.to_ms
json.voters_count @voted_concert ? (concert.get_concert_base_number(@voted_concert.city_id) + concert.voters_count) : 0
json.end_date concert.end_date.to_ms
json.poster concert.poster_url || ''
json.is_followed concert.id.in?(@followed_concerts)
json.is_voted @voted_concert
@voted_concert ? (json.voted_city { json.partial!("api/v1/cities/city", {city: City.find_by_id(@voted_concert.city_id)}) }) : ( json.voted_city nil )
json.sharing_page 'http://www.dan-che.com'

if need_stars
  json.stars{ json.array! concert.stars.is_display, partial: "api/v1/stars/star", as: :star }
end

if need_topics
  json.topics{ json.array! concert.topics, partial: "api/v1/topics/topic", as: :topic }
end

if need_shows
  json.shows{ json.array! concert.shows.is_display, partial: "api/v1/shows/show", as: :show }
end
