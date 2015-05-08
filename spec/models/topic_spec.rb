require 'rails_helper'

RSpec.describe Topic, :type => :model do
  context "validate" do
     it "star's topic without city_id should be valid" do
       star = create :star
       topic = create :topic, subject_type: Star.name, subject_id: star.id
       expect(topic.valid?).to be true
     end

     #it "concert's topic without city_id should be invalid" do
     #  concert=  create :concert
     #  topic = build :topic, subject_type: Concert.name, subject_id: concert.id
     #  expect(topic.valid?).to be false
     #  expect(topic).to have(1).error_on(:city_id)
     #end
  end
end
