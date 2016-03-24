require 'rails_helper'

RSpec.describe Event, :type => :model do
  describe "#stadium_map_url" do
    it "should use show's stadium_map_url if is Yongle's event" do
      show = create(:show, source: Show.sources[:yongle])
      event = create(:event, show_id: show.id)
      expect(event.stadium_map_url).to eq show.stadium_map_url
    end

    it "should mount ImageUploader if is not Yongle's event" do
      show = create(:show, source: Show.sources[:hoishow])
      event = create(:event, show_id: show.id)
      expect(event.stadium_map_url).not_to eq show.stadium_map_url
      expect(event.stadium_map_url).not_to eq nil
    end
  end
end
