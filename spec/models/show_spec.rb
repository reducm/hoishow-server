require 'spec_helper'

describe Show do
  context "validation" do
    it "min_price should smaller than max_price" do
      show = build(:show, min_price: 10.0, max_price: 5.0)
      expect(show.valid?).to be_false
      expect(show).to have(1).error_on(:min_price)
    end

    it "concert should be presence" do
      show = build(:show, concert: nil)
      expect(show.valid?).to be_false
      expect(show).to have(1).error_on(:concert)
    end  

    it "stadium should be presence" do
      show = build(:show, stadium: nil)
      expect(show.valid?).to be_false
      expect(show).to have(1).error_on(:stadium)
    end  
  end
end
