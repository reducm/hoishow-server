require 'spec_helper'

RSpec.describe Open::V1::SeatsController, :type => :controller do
  render_views
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
  end

  let(:city) { create :city }
  let(:stadium) { create :stadium, city: city }
  let(:concert) { create :concert }
  let(:show) { create :show, city: city, stadium: stadium, concert: concert }
  let(:area) { create :area, stadium: stadium }

  before :each do
    show.show_area_relations.create(area_id: area.id, channels: 'bike', is_sold_out: [true, false].sample)
  end


  context "#action index" do
    before('each') do
      15.times do
        create("#{['avaliable', 'locked', 'unused'].sample}_seat", show_id: show.id, area_id: area.id)
      end
    end

    it "should get all seats data" do
      get :index, show_id: show.id, area_id: area.id

      expect(json[:result_code]).to eq 0
      expect(json[:data].size).to eq 15
      json[:data].each do |d|
        seat = Seat.find(d[:id])
        expect(d[:name]).to eq seat.name
        expect(d[:show_id]).to eq seat.show.id
        expect(d[:area_id].to_d).to eq seat.area.id
        expect(d[:price]).to eq seat.price.to_f
        expect(d[:status]).to eq seat.status
        expect(d[:row]).to eq seat.row
        expect(d[:column]).to eq seat.column
      end
    end

    it 'will return error when show id was wrong' do
      get :index, show_id: -1

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该演出'
    end

    it 'will return error when area id was wrong' do
      get :index, area_id: -1, show_id: show.id

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该区域'
    end
  end

  context "#action show" do
    let(:seat) { create :avaliable_seat, show: show, area: area }

    it 'should return current seat with current id' do

      get :show, id: seat.id, show_id: show.id, area_id: area.id

      expect(json[:result_code]).to eq 0
      d = json[:data]
      expect(d[:id]).to eq seat.id
      expect(d[:name]).to eq seat.name
      expect(d[:show_id]).to eq seat.show.id
      expect(d[:area_id].to_d).to eq seat.area.id
      expect(d[:price]).to eq seat.price
      expect(d[:status]).to eq 'avaliable'
      expect(d[:row]).to eq seat.row
      expect(d[:column]).to eq seat.column
    end

    it 'will return error when area no found' do
      get :show, id: seat.id, area_id: -1, show_id: show.id

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该区域'
    end

    it 'will return error when show id was wrong' do
      get :show, id: seat.id, area_id: area.id, show_id: -1

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该演出'
    end

    it 'will return error when seat no found' do
      get :show, id: -1, area_id: area.id, show_id: show.id

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该座位'
    end
  end
end
