require 'spec_helper'

describe Show do
  context "validation" do
    it "min_price should smaller than max_price" do
      show = build(:show, min_price: 10.0, max_price: 5.0)
      expect(show.valid?).to be false
      expect(show).to have(1).error_on(:min_price)
    end

    it "concert should be presence" do
      show = build(:show, concert: nil)
      expect(show.valid?).to be false
      expect(show).to have(1).error_on(:concert)
    end  

    it "stadium should be presence" do
      show = build(:show, stadium: nil)
      expect(show.valid?).to be false
      expect(show).to have(1).error_on(:stadium)
    end  

    it "response to stars" do
      show = create(:show)
      expect(show.respond_to?(:stars)).to be true
      expect(show.stars).to eq show.concert.stars
    end
  end

  context "test paginate" do
    before('each') do
      200.times do
        create :show
      end
    end
    it "per 20" do
      expect( Show.page(2).size ).to eq 20
    end

    it "page2's model should be correct" do
      shows = Show.all
      expect(shows.index Show.page(2).first).to be 20
    end
  end
end
