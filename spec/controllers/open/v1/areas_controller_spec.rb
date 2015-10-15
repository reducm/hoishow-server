require 'spec_helper'

RSpec.describe Open::V1::AreasController, :type => :controller do
  render_views
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
  end

  let(:city) { create :city }
  let(:stadium) { create :stadium, city: city }
  let(:concert) { create :concert }
  let(:show) { create :show, city: city, stadium: stadium, concert: concert }

  context "#action index" do
    before('each') do
      15.times do
        area = create :area, stadium: stadium
        show.show_area_relations.create(area_id: area.id, channels: 'bike_ticket', seats_count: 60, left_seats: 60)
      end
    end

    it "should get all areas data by show_id" do
      get :index, encrypted_params_in_open({show_id: show.id})

      expect(json[:result_code]).to eq 0
      expect(json[:data].size).to eq 15
      json[:data].each do |d|
        a = Area.find(d[:id])
        relation = show.show_area_relations.where(area_id: a.id).first
        expect(d[:id]).to eq a.id
        expect(d[:name]).to eq a.name
        expect(d[:stadium_id]).to eq a.stadium_id
        expect(d[:seats_count].to_i).to eq relation.seats_count.to_i
        expect(d[:price]).to eq relation.price.to_f
        expect(d[:is_sold_out]).to eq relation.is_sold_out || relation.channels.present? && !relation.channels.include?('bike_ticket')
        expect(d[:seats_left]).to eq show.area_seats_left(a)
        expect(d[:seats_map]).to eq seats_map_path(show_id: show.id, area_id: a.id)
      end
    end

    it 'will return error when show id was wrong' do
      get :index, encrypted_params_in_open({show_id: -1})

      expect(response.status).to eq 404
      expect(json[:message]).to eq '找不到该数据'
    end
  end

  context "#action show" do
    it 'should return current area with current id' do
      a = create :area, stadium: stadium
      show.show_area_relations.create(area_id: a.id, channels: 'bike_ticket', seats_count: 60, left_seats: 60)

      get :show, encrypted_params_in_open({id: a.id, show_id: show.id})

      expect(json[:result_code]).to eq 0
      d = json[:data]
      relation = show.show_area_relations.where(area_id: a.id).first
      expect(d[:id]).to eq a.id
      expect(d[:name]).to eq a.name
      expect(d[:stadium_id]).to eq a.stadium_id
      expect(d[:seats_count].to_i).to eq relation.seats_count.to_i
      expect(d[:price]).to eq relation.price.to_f
      expect(d[:is_sold_out]).to eq relation.is_sold_out || relation.channels.present? && !relation.channels.include?('bike_ticket')
      expect(d[:seats_left]).to eq show.area_seats_left(a)
      expect(d[:seats_map]).to eq seats_map_path(show_id: show.id, area_id: a.id)
    end

    it 'will return error when area no found' do
      get :show, encrypted_params_in_open({id: -1, show_id: show.id})

      expect(response.status).to eq 404
      expect(json[:message]).to eq '找不到该数据'
    end

    it 'will return error when show id was wrong' do
      get :show, encrypted_params_in_open({id: -1, show_id: -1})

      expect(response.status).to eq 404
      expect(json[:message]).to eq '找不到该数据'
    end
  end

  context "#action seats_info" do
    it "should return current area seats data" do
      seats_info = generate_seats(2, 5, Area::SEAT_AVALIABLE)
      a = create :area, stadium: stadium, seats_info: seats_info
      show.show_area_relations.create(area_id: a.id, channels: 'bike_ticket', seats_count: 60, left_seats: 60)
      # 10.times {create :seat, area: a, show: show}

      get :seats_info, encrypted_params_in_open({id: a.id, show_id: show.id})
      expect(json[:result_code]).to eq 0
      expect(json[:data][:seats].size).to eq 2
      expect(json[:data][:seats]['1'].size).to eq 5
      expect(json[:data].has_key?('total') ).to be_truthy
      expect(json[:data].has_key?('sort_by') ).to be_truthy
      expect(json[:data].has_key?('selled') ).to be_truthy
    end
  end
end
