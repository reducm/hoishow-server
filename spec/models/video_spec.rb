require 'spec_helper'

describe Video do
  context "validation" do
    it "source should be presences" do
      video = Video.new(star_id: 2)
      expect(video.valid?).to be_falsey
      expect(video).to have(1).error_on(:source)
    end

    it "star_id should be presences" do
      video = Video.new(source: "ooxx.mp4")
      expect(video.valid?).to be_falsey
      expect(video).to have(1).error_on(:star_id)
    end
  end
end
