require 'rails_helper'

RSpec.describe District, :type => :model do
  context "uniqueness" do
    it "One city should not have same district_name" do
      @city = create :city
      district1 = create :district, city: @city, name: "123"
      district2 = build :district, city: @city, name: "123"
      expect(district2.valid?).to be false
    end

    it "Two city with same district_name should be ok" do
      city1 = create :city
      city2 = create :city
      district1 = create :district, name: "123", city: city1
      district2 = create :district, name: "123", city: city2
      expect(district1.valid?).to be true
      expect(district2.valid?).to be true
    end
  end
end
