module Operation::ConcertsHelper
  def get_city_voted_count(city)
    UserVoteConcert.where(city_id: city.id).count
  end

  def get_no_concert_cities(concert)
    ids = concert.concert_city_relations.map(&:city_id).compact.uniq
    ids.empty? ? City.all : City.where("id not in (?)", ids)
  end
end
