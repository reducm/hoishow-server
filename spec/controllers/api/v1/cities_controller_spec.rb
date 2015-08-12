require 'rails_helper'

RSpec.describe Api::V1::CitiesController, :type => :controller do
  render_views

  context "#index" do
    before('each') do
      30.times {create :city}
    end

    it "should get 20 cities" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 10
    end    

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("pinyin")
      expect(response.body).to include("name")
      expect(response.body).to include("code")
    end
  end

  context "#index paginate test" do
    before('each') do
      100.times {create :city}
    end
    
    it "with page params" do
      get :index, with_key(page: 2, format: :json)
      cities_id = City.pluck(:id)
      expect(cities_id.index JSON.parse(response.body).first["id"].to_i).to eq 10
    end
  end

end
