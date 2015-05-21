json.partial! "concert", { concert: @concert, need_stars: true, need_topics: true, need_shows: true  }
json.cities do
  json.array! @concert.cities do|city|
    json.partial! "api/v1/cities/city", city: city
  end
end
json.city_rank do
  json.partial! "city_vote_rank", { cities: @concert.cities, concert: @concert }
end
