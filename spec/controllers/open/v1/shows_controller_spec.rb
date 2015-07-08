require 'spec_helper'

RSpec.describe Open::V1::ShowsController, :type => :controller do
  render_views
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
  end

  let(:city) { create :city }
  let(:stadium) { create :stadium, city: city }
  let(:concert) { create :concert }

  context "#action index" do
    it "should get all shows data" do
      15.times { create :show, city: city, stadium: stadium, concert: concert }

      get :index

      expect(json[:result_code]).to eq 0
      expect(json[:data].size).to eq 15
      json[:data].each do |d|
        s = Show.find(d[:id])
        expect(s).not_to be_nil
        expect(d[:name]).to eq s.name
        expect(d[:concert_id]).to eq s.concert.id
        expect(d[:concert_name]).to eq s.concert.name
        expect(d[:city_id]).to eq s.city.id
        expect(d[:city_name]).to eq s.city.name
        expect(d[:stadium_id]).to eq s.stadium.id
        expect(d[:stadium_name]).to eq s.stadium.name
        expect(d[:show_time]).to eq s.show_time.to_ms
        expect(d[:poster]).to eq s.poster_url
        expect(d[:ticket_pic]).to eq s.ticket_pic_url
        expect(d[:description]).to eq description_path(subject_id: s.id, subject_type: "Show")
        expect(d[:description_time]).to eq s.description_time
        expect(d[:is_top]).to eq s.is_top
        expect(d[:status]).to eq s.status
        expect(d[:ticket_type]).to eq s.ticket_type
        expect(d[:stadium_map]).to eq s.stadium_map_url
        expect(d[:seat_type]).to eq s.seat_type
        expect(d[:mode]).to eq s.mode
      end
    end
  end

  context "#action show" do
    let(:s) { create :show, city: city, stadium: stadium, concert: concert }

    it 'should return current show with current id' do
      get :show, id: s.id

      expect(json[:result_code]).to eq 0
      d = json[:data]
      expect(d[:id]).to eq s.id
      expect(d[:name]).to eq s.name
      expect(d[:concert_id]).to eq s.concert.id
      expect(d[:concert_name]).to eq s.concert.name
      expect(d[:city_id]).to eq s.city.id
      expect(d[:city_name]).to eq s.city.name
      expect(d[:stadium_id]).to eq s.stadium.id
      expect(d[:stadium_name]).to eq s.stadium.name
      expect(d[:show_time]).to eq s.show_time.to_ms # need to fix
      expect(d[:poster]).to eq s.poster_url
      expect(d[:ticket_pic]).to eq s.ticket_pic_url
      expect(d[:description]).to eq description_path(subject_id: s.id, subject_type: "Show")
      expect(d[:description_time]).to eq s.description_time
      expect(d[:is_top]).to eq s.is_top
      expect(d[:status]).to eq s.status
      expect(d[:ticket_type]).to eq s.ticket_type
      expect(d[:stadium_map]).to eq s.stadium_map_url
      expect(d[:seat_type]).to eq s.seat_type
      expect(d[:mode]).to eq s.mode
    end

    it 'will return error when show no found' do
      get :show, id: -1

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该演出'
    end
  end
end
