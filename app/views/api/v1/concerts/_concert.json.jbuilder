need_stars ||= false
need_topics||= false
need_shows ||= false
user ||= nil

@followed_concerts = user.present? ? user.follow_concerts.pluck(:id) : []
@voted_concerts = user.present? ? user.vote_concerts.pluck(:id) : []

json.(concert, :id, :name, :description, :status, :followers_count, :shows_count, :voters_count)

json.start_date concert.start_date.to_ms
json.end_date concert.end_date.to_ms
json.poster concert.poster.url || ''
json.is_followed concert.id.in?(@followed_concerts) ? true : false
json.is_voted concert.id.in?(@voted_concerts) ? true : false
if need_stars
  json.stars{ json.array! concert.stars, partial: "api/v1/stars/star", as: :star }
end

if need_topics
  json.topics{ json.array! concert.topics, partial: "api/v1/topics/topic", as: :topic }
end

if need_shows
  json.shows{ json.array! concert.shows, partial: "api/v1/shows/show", as: :show }
end
