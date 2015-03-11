require 'spec_helper'

describe ConcertCityRelation do
  before :each do
    @city = create :city
    @city2 = create :city
    @concert = create :concert
    @concert2 = create :concert
  end

  context "city and concert has_many ships" do
    it "create has_and_belongs_to_many should success" do
      @city.concert_city_relations.create(concert: @concert)
      @city.concert_city_relations.create(concert: @concert2)
      @concert.concert_city_relations.create(city: @city2)
      @concert2.concert_city_relations.create(city: @city2)

      expect(@city.in? @concert.cities).to be_true
      expect(@city.in? @concert2.cities).to be_true
      expect(@city2.in? @concert.cities).to be_true
      expect(@city2.in? @concert2.cities).to be_true
    end
  end
end
