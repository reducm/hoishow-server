require 'rails_helper'

RSpec.describe Api::V1::StadiumsController, :type => :controller do
  render_views

  context "#index" do
    before('each') do
      30.times {create :stadium}
    end

    it "should get 20 stadiums" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end    

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
      expect(response.body).to include("address")
      expect(response.body).to include("longitude")
      expect(response.body).to include("latitude")
    end
  end

  context "#index paginate test" do
    before('each') do
      100.times {create :stadium}
    end
    
    it "with page params" do
      get :index, with_key(page: 2, format: :json)
      stadiums_id = Stadium.pluck(:id)
      expect(stadiums_id.index JSON.parse(response.body).first["id"].to_i).to eq 20
    end
  end

end
