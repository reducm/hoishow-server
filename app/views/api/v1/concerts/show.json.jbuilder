json.partial! "concert", { concert: @concert, user: @user, need_stars: true, need_comments: true, need_shows: true  }
json.cities do
  json.array! concert.cities do|city|
    json.partial! "api/v1/cities/city", city: city
  end
end
json.city_rank do
  json.partial! "city_vote_rank", { cities: @concert.cities.to_a, concert: @concert }
end
