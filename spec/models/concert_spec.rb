require 'spec_helper'

describe Concert do
  context "test paginate" do
    before('each') do
      200.times do
        create :concert
      end
    end
    it "per 20" do
      expect( Concert.page(2).size ).to eq 20
    end

    it "page2's model should be correct" do
      concerts = Concert.all
      expect(concerts.index Concert.page(2).first).to be 20
    end
  end
end
