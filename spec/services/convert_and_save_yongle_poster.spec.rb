require 'spec_helper'

describe YongleService::Fetcher do
  let(:show) { create(:show, poster: nil) }

  context "#fetch_image" do
    it "should convert and save poster" do
      YongleService::Fetcher.fetch_image(show.id, Rails.root.join("spec/fixtures/yongle_poster_sample.jpg"), 'poster') # before
      poster = MiniMagick::Image.open(Rails.root.join("public#{show.reload.poster_url}")) # after
      expect(poster[:width]).to eq 720
      expect(poster[:height]).to eq 405
    end  
  end
end
