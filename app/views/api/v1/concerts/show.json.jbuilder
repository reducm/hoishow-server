json.partial! "concert", { concert: @concert, need_stars: true, need_topics: true, need_shows: true  }

json.cities do
  json.partial! "city_vote_rank", { cities: @concert.cities, concert: @concert }
end
