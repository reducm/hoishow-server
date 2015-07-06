require 'spec_helper'

RSpec.describe Open::V1::OrdersController, :type => :controller do
  render_views
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
  end

  let(:city) { create :city }
  let(:stadium) { create :stadium, city: city }
  let(:concert) { create :concert }
  let(:show) { create :show, city: city, stadium: stadium, concert: concert }
  let(:area) { create :area, stadium: stadium }
  let(:order) do
    o = Order.init_from_show(show)
    o.user_mobile = '138001380000'
    o.save!
    o
  end

  before :each do
    show.show_area_relations.create(area_id: area.id, channels: 'bike', is_sold_out: [true, false].sample)
  end

  context "#action show" do

    before :each do
      2.times { create :selectable_tickets, order: order, area: area, show: show }
    end

    it 'should return current order info with current out_id' do

      get :show, out_id: order.out_id, mobile: order.user_mobile # user id ?

      expect(json[:result_code]).to eq 0
      d = json[:data]
      expect(d[:out_id]).to eq order.out_id
      expect(d[:amount]).to eq order.amount
      expect(d[:concert_id]).to eq order.concert_id
      expect(d[:concert_name]).to eq order.concert_name
      expect(d[:show_id]).to eq order.show_id
      expect(d[:show_name]).to eq order.show_name
      expect(d[:stadium_id]).to eq order.stadium_id
      expect(d[:stadium_name]).to eq order.stadium_name
      expect(d[:city_id]).to eq order.city_id
      expect(d[:city_name]).to eq order.city_name
      expect(d[:status]).to eq 'pending'
      expect(d[:poster]).to eq order.show.poster_url
      expect(d[:tickets_count]).to eq order.tickets_count
      expect(d[:show_time]).to eq order.show_time.to_ms
      expect(d[:ticket_type]).to eq order.show.ticket_type
      expect(d[:qr_url]).to eq show_for_qr_scan_api_v1_order_path(order)
      # expect(d[:valid_time]).to eq order.valid_time.to_ms
      # about tickets
      expect(d[:tickets]).not_to be_blank
      expect(d[:tickets].size).to eq order.tickets.size
      d[:tickets].each do |t|
        ticket = order.tickets.find_by(code: t[:code])
        expect(t[:area_name]).to eq ticket.area.name
        expect(t[:price]).to eq ticket.price.to_f.to_s
        expect(t[:seat_name]).to eq ticket.seat_name
        expect(t[:status]).to eq ticket.status
      end
      # about express
      # express = what ?
      # expect(d[:user_mobile]).to eq express.user_mobile
      # expect(d[:user_name]).to eq(order.user_name || expresses.user_name)
      # expect(d[:express_id]).to eq express.id
      # expect(d[:district_address]).to eq express.district
      # expect(d[:express_code]).to eq order.express_id
      # expect(d[:user_address]).to eq express.user_address
      # expect(d[:province_address]).to eq express.province
      # expect(d[:city_address]).to eq express.city
    end

    it 'will return error when order no found' do
      get :show, out_id: -1, mobile: order.user_mobile # user id ?

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该订单'
    end

    it 'will return error when user mobile was wrong' do
      # test the user mobile
    end
  end

  context '# action create' do
    context 'selected' do
      it 'will create order with current params' do
        params = {}
        expect{post :create, params}.to change(show.orders, :count).by(1)
        expect(json[:result_code]).to 0
        # test order detail
      end

      # error test
    end

    context 'selectable' do
      it 'will create order with current params' do
        params = {}
        expect{post :create, params}.to change(show.orders, :count).by(1)
        expect(json[:result_code]).to 0
        # test order detail
      end

      # error test
    end
  end

  context '# action unlock_seat' do
    it 'will return success when unlock ok when outdate' do
      expect(order.status).to eq 'pending'
      post :unlock_seat, out_id: order.out_id, mobile: order.user_mobile, reason: 'outdate' # user id ?

      expect(json[:result_code]).to eq 0
      order.reload
      expect(order.status).to eq 'outdate'
    end

    it 'will return success when unlock ok when outdate' do
      # order.pre_pay!
      # order.success_pay!
      expect(order.status).to eq 'success'
      post :unlock_seat, out_id: order.out_id, mobile: order.user_mobile, reason: 'refund' # user id ?

      expect(json[:result_code]).to eq 0
      order.reload
      expect(order.status).to 'refund'
    end

    it 'will return error when order no found' do
      get :show, out_id: -1, mobile: order.user_mobile # user id ?

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该订单'
    end

    it 'will return error when user mobile was wrong' do
      # test the user mobile
    end
  end

  context '# action confirm' do
    it 'will return success when confiemed' do
      expect(order.status).to eq 'pending'
      post :confirm, out_id: order.out_id, mobile: order.user_mobile # user id ?

      expect(json[:result_code]).to eq 0
      order.reload
      expect(order.status).to 'success'
    end

    it 'will return error when order no found' do
      get :show, out_id: -1, mobile: order.user_mobile # user id ?

      expect(json[:result_code]).to eq 4004
      expect(json[:message]).to eq '找不到该订单'
    end

    it 'will return error when user mobile was wrong' do
      # test the user mobile
    end
  end
end
