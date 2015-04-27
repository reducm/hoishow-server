module Operation::ConcertsHelper
  def get_city_voted_count(city)
    UserVoteConcert.where(city_id: city.id).count
  end

  def get_no_concert_cities(concert)
    ids = concert.concert_city_relations.map(&:city_id).compact.uniq
    City.where("id not in (?)", ids).map {|city| [city.id, city.name]}
  end
end
