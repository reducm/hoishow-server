require 'spec_helper'

describe Star do
  context "validation" do
    it "star name should be presences" do
      star = Star.new
      expect(star.valid?).to be_falsey
      expect(star).to have(1).error_on(:name)
    end
  end
end
