require 'spec_helper'

describe Star do
  context "validation" do
    it "star name should be presences" do
      star = Star.new
      expect(star.valid?).to be_falsey
      expect(star).to have(1).error_on(:name)
    end

    it "star's video should be valid" do
      star = create(:star) 
      video = Video.new(id: star.id)
      expect(video.valid?).to be_falsey
      expect(video).to have(1).error_on(:source)
    end
  end

  context "scope" do
    it "should get star with is_display" do
      star = create(:star) 
      expect(star.is_display).to be_truthy
      expect(Star.is_display.count).to eq 1
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

  context "#search" do
    it "search should be ok" do
      10.times{|n| create(:star, name: "Tom#{n}")}
      expect(Star.search("om").count).to eq 10
      expect(Star.search("t").count).to eq 10
      expect(Star.search("tom").count).to eq 10
    end
  end

  context "test paginate" do
    before('each') do
      200.times do
        create :star
      end
    end
    it "per 20" do
      expect( Star.page(2).size ).to eq 20
    end

    it "page2's model should be correct" do
      stars = Star.all
      expect(stars.index Star.page(2).first).to be 20
    end
  end

end
