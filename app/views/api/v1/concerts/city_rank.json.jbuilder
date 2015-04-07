json.array! @cities do |city|
  json.partial! "api/v1/cities/city", locals: {city: city}
  json.city_vote_count UserVoteConcert.where(concert_id: @concert.id, city_id: city.id).count
end


