<%# encoding: utf-8 %>

need_stars ||= false
need_topics||= false
need_shows ||= false
@user ||= nil

@followed_concerts = @user.present? ? @user.follow_concerts.pluck(:id) : []
@voted_concert = @user.present? ? @user.user_vote_concerts.where(concert_id: concert.id).first : nil

json.(concert, :id, :name, :status, :is_top, :followers_count, :shows_count, :voters_count)

json.description description_path(subject_id: concert.id, subject_type: "Concert")
json.start_date concert.start_date.to_ms
json.end_date concert.end_date.to_ms
json.poster concert.poster_url || ''
json.is_followed concert.id.in?(@followed_concerts) ? true : false
json.is_voted @voted_concert ? true : false
json.voted_city @voted_concert

if need_stars
  json.stars{ json.array! concert.stars, partial: "api/v1/stars/star", as: :star }
end

if need_topics
  json.topics{ json.array! concert.topics, partial: "api/v1/topics/topic", as: :topic }
end

if need_shows
  json.shows{ json.array! concert.shows, partial: "api/v1/shows/show", as: :show }
end
