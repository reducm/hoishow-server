result ||= []
cities.each do |city|
  hash = city.attributes
  hash.merge!({"vote_count" => UserVoteConcert.where(concert_id: concert.id, city_id: city.id).count})
  result.push(hash)
end

#sort
result = result.sort!{|x, y| x["vote_count"] <=> y["vote_count"]}.reverse

json.array! result do |city_hash|
  city = cities.select{|city| city.id == city_hash["id"]}.first
  json.partial! "api/v1/cities/city", city: city
  json.vote_count city_hash["vote_count"]
end
