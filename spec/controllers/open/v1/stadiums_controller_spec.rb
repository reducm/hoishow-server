require 'spec_helper'

RSpec.describe Open::V1::StadiumsController, :type => :controller do
  render_views
  before(:each) do
    request.env["HTTP_ACCEPT"] = 'application/json'
    allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
    @city = create :city
  end

  context "#action index" do
    before('each') do
      15.times {create :stadium, city_id: @city.id}
    end

    it "should get all stadiums data" do
      get :index

      expect(json[:result_code]).to eq 0
      expect(json[:data].size).to eq 15
      json[:data].each do |d|
        stadium = Stadium.find(d[:id])
        expect(d[:id]).to eq stadium.id
        expect(d[:name]).to eq stadium.name
        expect(d[:address]).to eq stadium.address
        expect(d[:longitude].to_d).to eq stadium.longitude
        expect(d[:latitude].to_d).to eq stadium.latitude
        expect(d[:city_id]).to eq stadium.city.id
      end
    end
  end

  context "#action show" do
    it 'should return current stadium with current id' do
      stadium = create :stadium, city_id: @city.id
      get :show, id: stadium.id

      expect(json[:result_code]).to eq 0
      data = json[:data]
      expect(data[:id]).to eq stadium.id
      expect(data[:name]).to eq stadium.name
      expect(data[:address]).to eq stadium.address
      expect(data[:longitude].to_d).to eq stadium.longitude
      expect(data[:latitude].to_d).to eq stadium.latitude
      expect(data[:city_id]).to eq stadium.city.id
    end

    it 'will return error when stadium no found' do
      get :show, id: -1

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该场馆'
    end
  end
end
