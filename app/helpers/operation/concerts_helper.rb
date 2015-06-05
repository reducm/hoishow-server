module Operation::ConcertsHelper
  def get_city_voted_count(concert, city)
    concert.user_vote_concerts.where(city_id: city.id).count
  end

  def get_city_concert_base_number(concert, city)
    concert.concert_city_relations.where(city_id: city.id).first.base_number
  end

  def get_no_concert_cities(concert)
    ids = concert.concert_city_relations.map(&:city_id).compact.uniq
    ids.empty? ? City.all : City.where("id not in (?)", ids)
  end
end
