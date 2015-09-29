require 'spec_helper'

RSpec.describe Open::V1::SeatsController, :type => :controller do
  render_views
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
  end

  before :each do
    show = create :show
    area = create :area
    10.times {create :seat, show: show, area: area}
  end

  context '#action query_seats' do
    it 'should return seats info success' do
      ids = Seat.limit(5).map{|s| s.id.to_s}
      get :query_seats, encrypted_params_in_open({seat_ids: ids})
      expect(json[:result_code]).to eq 0
      expect(json[:data].size).to eq 5
    end

    it 'should return error if cannot find seat id' do
      get :query_seats, encrypted_params_in_open({seat_ids: 0})
      expect(json[:result_code]).to eq 2001
      expect(json[:message]).to eq '找不到该数据'
    end
  end
end
