require 'rails_helper'

RSpec.describe Api::V1::AreasController, :type => :controller do
  render_views

  before('each') do
   30.times do |i| 
      create(:area)
    end 
  end

  context "#index" do
    it "should get 20 areas" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end    

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("name")
      expect(response.body).to include("seats_count")
      expect(response.body).to include("stadium_id")
      expect(response.body).to include("stadium")
      expect(response.body).to include("created_at")
      expect(response.body).to include("updated_at")
    end

    it "stadium should has something" do
      get :index, with_key(format: :json)
      20.times do |n|
        expect(JSON.parse( response.body )[n-1]["stadium"].size > 0 ).to be true
      end
    end
  end
end
