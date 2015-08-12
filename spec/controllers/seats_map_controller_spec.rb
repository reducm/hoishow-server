require 'rails_helper'

RSpec.describe SeatsMapController, :type => :controller do
  render_views

  describe "#show" do
    it "should get show's seats" do
      show = create :show
      area = create :area
      create :show_area_relation, show_id: show.id, area_id: area.id
      seats = []
      5.times do
        seat = create :seat, show_id: show.id, area_id: area.id
        seats << seat
      end

      get :show, show_id: show.id, area_id: area.id
      expect(show.seats.where(area_id: area.id)).to eq seats
    end
  end
end
