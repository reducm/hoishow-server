require 'rails_helper'

RSpec.describe Api::Open::V1::CitiesController, :type => :controller do
  render_views

  context "#index with correct out channel params" do
    before('each') do
      30.times {create :city}
    end

    it "should get 30 cities" do
      get :index, with_out_channel_params(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 30
    end    

    it "should has attributes" do
      get :index, with_out_channel_params(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
    end
  end

  context "#index with incorrect out channel params" do
    it "should return code 1003 if params missing" do
      get :index, format: :json
      expect(JSON.parse(response.body)["result_code"]).to eq "1003" 
    end    
    it "should return code 1001 if channel not exist" do
      get :index, api_key: "hah", timestamp: 11, sign: "pjpl", format: :json
      expect(JSON.parse(response.body)["result_code"]).to eq "1001" 
    end
    it "should return code 1002 if request time has passed 10 minutes" do
      @auth = ApiAuth.create(user: "jas")
      timestamp = (Time.now - 601).to_i
      sign = Digest::MD5.hexdigest("api_key=#{@auth.key}&timestamp=#{timestamp}#{@auth.secretcode}")
      get :index, api_key: @auth.key, timestamp: timestamp, sign: sign, format: :json
      expect(JSON.parse(response.body)["result_code"]).to eq "1002" 
    end
    it "should return code 1002 if sign is not the same" do
      @auth = ApiAuth.create(user: "jas")
      timestamp = Time.now.to_i
      get :index, api_key: @auth.key, timestamp: timestamp, sign: "xxxxxxxx", format: :json
      expect(JSON.parse(response.body)["result_code"]).to eq "1002" 
    end
  end
end
