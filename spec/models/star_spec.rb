require 'spec_helper'

describe Star do
  context "validation" do
    it "star name should be presences" do
      star = Star.new
      expect(star.valid?).to be_falsey
      expect(star).to have(1).error_on(:name)
    end
  end

  context "#shows" do
    it "sholud has shows" do
      @star = create :star
      3.times do
        concert = create(:concert)
        3.times{|n| create(:show, concert: concert, name: "fuck show #{n}") }
        @star.hoi_concert(concert)
      end
      expect(@star.shows.size > 0).to be true
    end
  end
end
