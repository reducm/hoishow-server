json.partial! "concert", { concert: @concert, user: @user, need_stars: true, need_comments: true, need_shows: true  }
json.cities []
json.city_rank do
  json.partial! "city_vote_rank", { cities: @concert.cities.to_a, concert: @concert }
end
