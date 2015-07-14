require 'spec_helper'

def sign_params(params)
  params[:timestamp] = Time.now.to_i
  params[:api_key] = auth.key
  sign = params.sort.to_h.map do |key, value|
    "#{key.to_s}=#{value}"
  end.join("&") << auth.secretcode
  sign = Digest::MD5.hexdigest(sign).upcase
  params.tap { |p| p[:sign] = sign }
end

RSpec.describe Open::V1::OrdersController, :type => :controller do
  render_views
  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    # allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
  end

  let(:city) { create :city }
  let(:stadium) { create :stadium, city: city }
  let(:concert) { create :concert }
  let(:show) { create :show, city: city, stadium: stadium, concert: concert,
    seat_type: 1 }
  let(:show2) { create :show, city: city, stadium: stadium, concert: concert,
    seat_type: 0 }
  let(:area) { create :area, stadium: stadium }
  let(:area2) { create :area, stadium: stadium }
  let(:order) do
    o = Order.init_from_show(show)
    o.user_mobile = '15900001111'
    o.channel = Order.channels[:bike_ticket]
    o.save!
    o
  end
  let(:auth) { ApiAuth.create(user: "dancheServer", secretcode: 'hehe') }
  let(:user) { User.create(mobile: '15900001111', channel: 2, bike_user_id: 300) }

  before :each do
    show.show_area_relations.create(area_id: area.id, channels: 'bike',
      is_sold_out: false, price: rand(300..500), seats_count: 2)
    show2.show_area_relations.create(area_id: area2.id, channels: 'bike',
      is_sold_out: false, price: rand(300..500), seats_count: 2)

    allow_any_instance_of(ApiAuth).to receive(:channel) { 'bike_ticket' }
  end

  context "#action show" do

    before :each do
      2.times { create :selectable_tickets, order: order, area: area, show: show }
      # allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
    end

    it 'should return current order info with current out_id' do
      params = sign_params({ mobile: order.user_mobile })
      params[:out_id] = order.out_id  # user id ?}
      get :show, params

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
      expect(d[:show_time]).to eq order.show_time.to_i
      expect(d[:ticket_type]).to eq order.show.ticket_type
      expect(d[:qr_url]).to eq show_for_qr_scan_api_v1_order_path(order)
      # expect(d[:valid_time]).to eq order.valid_time.to_i
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
      params = sign_params({mobile: order.user_mobile})
      params[:out_id] = -1
      get :show, params# user id ?

      expect(json[:result_code]).to eq 3006
      expect(json[:message]).to eq '订单不存在'
    end

    it 'will return error when user mobile was wrong' do
      # test the user mobile
    end
  end

  context '# action create' do
    context 'selected' do
      let(:params) { { show_id: show.id, area_id: area.id, mobile: '15900001111',
        bike_user_id: user.bike_user_id } }

      it 'will create order with current params' do
        params[:quantity] = 2

        expect{post :create, sign_params(params)}.to change(show.orders, :count).by(1)
        expect(json[:result_code]).to eq 0

        order = Order.last
        d = json[:data]
        expect(d[:out_id]).to eq order.out_id
        expect(d[:amount]).to eq order.amount.to_f.to_s
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
        expect(d[:show_time]).to eq order.show_time.to_i
        expect(d[:ticket_type]).to eq order.show.ticket_type
        expect(d[:qr_url]).to eq show_for_qr_scan_api_v1_order_path(order)
        expect(d[:user_mobile]).to eq '15900001111'
        # expect(d[:valid_time]).to eq order.valid_time.to_i
        # about tickets
        expect(d[:tickets]).not_to be_blank
        expect(d[:tickets].size).to eq 2
        d[:tickets].each do |t|
          ticket = order.tickets.find_by(code: t[:code])
          expect(t[:area_name]).to eq ticket.area.name || ''
          expect(t[:price]).to eq ticket.price.to_f.to_s
          expect(t[:seat_name]).to eq ticket.seat_name || ''
          expect(t[:status]).to eq ticket.status
        end
      end

      it 'will return error whan seat left' do
        params[:quantity] = 5

        post :create, sign_params(params)
        expect(json[:message]).to eq '购买票数大于该区剩余票数!'
      end

      it 'will return error whan show was sold out' do
        relation = ShowAreaRelation.where(show_id: show.id, area_id: area.id).first
        relation.update_attributes is_sold_out: true
        params[:quantity] = 2

        post :create, sign_params(params)
        expect(json[:message]).to eq '你所买的区域暂时不能买票, 请稍后再试'
      end

      it 'will return error when user phone was wrong' do
        params[:mobile] = 'xxx182939'

        post :create, sign_params(params)
        expect(json[:message]).to eq '手机号不正确'
      end

      it 'will return error whan show was sold out' do
        show.update_attributes status: 1
        params[:quantity] = 2

        post :create, sign_params(params)
        expect(json[:result_code]).to eq 2002
        expect(json[:message]).to eq '购票结束'
      end
    end

    context 'selectable' do
      before do
        show2.show_area_relations.create(area: area2, price: rand(300..500), seats_count: 2)
        3.times { create(:seat, area_id: area2.id, show: show2) }
      end

      let(:params) do
        {
          mobile: '15900001111', quantity: 1, area_id: area2.id, show_id: show2.id,
          bike_user_id: user.bike_user_id,
          areas: show2.areas.map do |area|
            {
              area_id: area2.id,
              seats: area2.seats.map do |s|
                { id: s.id, seat_no: s.name }
              end
            }
          end.to_json
        }
      end

      it 'will create order with current params' do
        expect{post :create, sign_params(params)}.to change(show2.orders, :count).by(1)
        expect(json[:result_code]).to eq 0
        order = Order.last

        d = json[:data]
        expect(d[:out_id]).to eq order.out_id
        expect(d[:amount]).to eq order.amount.to_f.to_s
        expect(d[:user_mobile]).to eq '15900001111'

        expect(d[:tickets]).not_to be_blank
        expect(d[:tickets].size).to eq show2.seats.count
        d[:tickets].each do |t|
          ticket = order.tickets.find_by(code: t[:code])
          expect(t[:area_name]).to eq ticket.area.name || ''
          expect(t[:price]).to eq ticket.price.to_f.to_s
          expect(t[:seat_name]).to eq ticket.seat_name || ''
          expect(t[:status]).to eq ticket.status
        end
      end

      it 'will return error when user phone was wrong' do
        params[:mobile] = 'xxx182939'

        post :create, sign_params(params)
        expect(json[:message]).to eq '手机号不正确'
      end

      it 'will return error when miss params areas' do
        params.delete(:areas)

        post :create, sign_params(params)
        expect(json[:message]).to eq '缺少 areas 参数'
      end

      it 'will return error when can not find user' do
        params.delete(:bike_user_id)

        post :create, sign_params(params)
        expect(json[:result_code]).to eq 3004
        expect(json[:message]).to eq '找不到该用户'
      end
    end
  end

  # context '# action unlock_seat' do
  #   let(:params) { { mobile: order.user_mobile, out_id: order.out_id } }
  #   before do
  #     # allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
  #   end
  #
  #   it 'will return success when unlock ok when outdate' do
  #     expect(order.status).to eq 'pending'
  #     params[:reason] = 'outdate'
  #     post :unlock_seat, sign_params(params)
  #
  #     expect(json[:result_code]).to eq 0
  #     order.reload
  #     expect(order.status).to eq 'outdate'
  #   end
  #
  #   it 'will return success when unlock ok when refund' do
  #     order.pre_pay!
  #     order.success_pay!
  #     expect(order.status).to eq 'success'
  #     params[:reason] = 'refund'
  #     post :unlock_seat, sign_params(params) # user id ?
  #
  #     expect(json[:result_code]).to eq 0
  #     order.reload
  #     expect(order.status).to eq 'refund'
  #   end
  #
  #   it 'will return error when order no found' do
  #     params[:out_id] = -1
  #     get :unlock_seat, sign_params(params)# user id ?
  #
  #     expect(json[:result_code]).to eq 3006
  #     expect(json[:message]).to eq '订单不存在'
  #   end
  #
  #   it 'will return error when user mobile was wrong' do
  #     params[:mobile] = 'xxx182939'
  #
  #     post :unlock_seat, sign_params(params)
  #     expect(json[:message]).to eq '手机号不正确'
  #   end
  #
  #   it 'will return error when unlock fail' do
  #     allow_any_instance_of(Order).to receive(:overtime!) do
  #       false
  #     end
  #     params[:reason] = 'outdate'
  #
  #     post :unlock_seat, sign_params(params)
  #     expect(json[:result_code]).to eq 3008
  #     expect(json[:message]).to eq '订单解锁失败'
  #   end
  #
  #   it 'will return error when params reason was wrong' do
  #     params[:reason] = 'heheh'
  #
  #     post :unlock_seat, sign_params(params)
  #     expect(json[:result_code]).to eq 3011
  #     expect(json[:message]).to eq '解锁原因错误'
  #   end
  # end

  context '# action confirm' do
    let(:params) do
      sign_params({ mobile: order.user_mobile }).tap { |p| p[:out_id] = order.out_id }
    end

    before do
      # allow_any_instance_of(Open::V1::ApplicationController).to receive(:api_verify) { true }
    end

    it 'will return success when confiemed' do
      expect(order.status).to eq 'pending'
      post :confirm, params # user id ?

      expect(json[:result_code]).to eq 0
      order.reload
      expect(order.status).to eq 'success'
    end

    it 'will return error when order no found' do
      params[:out_id] = -1

      get :show, params# user id ?

      expect(json[:result_code]).to eq 3006
      expect(json[:message]).to eq '订单不存在'
    end

    it 'will return error when user mobile was wrong' do
      wrong_params = { mobile: 'xxx182939' }
      pa = sign_params(wrong_params).tap { |p| p[:out_id] = order.out_id }

      post :confirm, pa
      expect(json[:message]).to eq '手机号不正确'
    end

    it 'will return error when unlock fail' do
      allow_any_instance_of(Order).to receive(:pre_pay!) do
        false
      end

      post :confirm, params
      expect(json[:result_code]).to eq 3012
      expect(json[:message]).to eq '订单确认失败'
    end

    it 'will update order adderss if show ticket was r_ticket' do
      show.update_attributes ticket_type: 'r_ticket'
      new_params = { user_name: 'xx先生', user_mobile: '15900001111',
       province: '广东省', city: '广州市', district: '海珠区', address: '呵呵',
       mobile: order.user_mobile}
      pa = sign_params(new_params).tap { |p| p[:out_id] = order.out_id }
      expect(order.status).to eq 'pending'
      post :confirm, pa # user id ?

      expect(json[:result_code]).to eq 0
      order.reload
      expect(order.status).to eq 'success'
      expect(order.user_name).to eq 'xx先生'
      expect(order.user_mobile).to eq '15900001111'
      expect(order.user_address).to eq '广东省广州市海珠区呵呵'
    end
  end

  context "# action check_inventory" do
    context "selected" do
      let(:params) { { show_id: show.id, area_id: area.id} }

      it 'should return ok when quantity less than seat left count' do
        params[:quantity] = 2
        get :check_inventory, sign_params(params)
        expect(json[:result_code]).to eq 0
        expect(json[:message]).to eq '请求成功'
      end

      it 'should return error when quantity large than seat left count' do
        params[:quantity] = 3
        get :check_inventory, sign_params(params)
        expect(json[:result_code]).to eq 2003
        expect(json[:message]).to eq '购买票数大于该区剩余票数!'
      end


      it 'will return error whan show was sold out' do
        relation = ShowAreaRelation.where(show_id: show.id, area_id: area.id).first
        relation.update_attributes is_sold_out: true
        params[:quantity] = 2

        get :check_inventory, sign_params(params)
        expect(json[:result_code]).to eq 3015
        expect(json[:message]).to eq '你所买的区域暂时不能买票, 请稍后再试'
      end

      it 'will return error whan show was sold out' do
        show.update_attributes status: 1
        params[:quantity] = 2

        get :check_inventory, sign_params(params)
        expect(json[:result_code]).to eq 2002
        expect(json[:message]).to eq '购票结束'
      end
    end

    context "selectable" do
      before do
        show2.show_area_relations.create(area: area2, price: rand(300..500), seats_count: 2)
        3.times { create(:seat, area_id: area2.id, show: show2, status: 0) }
      end

      let(:params) { { show_id: show2.id } }

      it 'should return ok when quantity less than seat left count' do
        params[:seats] = show2.seats.pluck(:id).to_json
        get :check_inventory, sign_params(params)
        expect(json[:result_code]).to eq 0
        expect(json[:message]).to eq '请求成功'
      end

      it 'should return error when seat was locked' do
        show2.seats.first.update_attributes(status: 1)
        params[:seats] = show2.seats.pluck(:id).to_json
        get :check_inventory, sign_params(params)
        expect(json[:result_code]).to eq 2004
        expect(json[:message]).to eq '座位已被占'
        expect(json[:unavaliable_seats]).to be_a(Array)
        un_seat = show2.seats.first
        expect(json[:unavaliable_seats][0][:id]).to eq un_seat.id
        expect(json[:unavaliable_seats][0][:name]).to eq un_seat.name
      end
    end
  end
end
