require 'spec_helper'

RSpec.describe Open::V1::CitiesController, :type => :controller do
  render_views
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
  end

  context "#action index" do
    before('each') do
      15.times {create :city}
    end

    it "should get all cities data" do
      get :index, encrypted_params_in_open

      expect(json[:result_code]).to eq 0
      expect(json[:data].size).to eq 15
      json[:data].each do |d|
        city = City.find(d[:id])
        expect(city).not_to be_nil
        expect(d[:name]).to eq city.name
      end
    end
  end
end
