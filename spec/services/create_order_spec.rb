require 'spec_helper'

describe CreateOrderLogic do
  before(:each) do
    @stadium = create(:stadium)
    @show1 = create(:show, stadium: @stadium, seat_type: Show.seat_types[:selected])
    @show2 = create(:show, stadium: @stadium, seat_type: Show.seat_types[:selectable])

    5.times{ create(:area, stadium: @stadium) }
    @stadium.areas.first(2).each_with_index do |area, i|
      r = @show1.show_area_relations.create(area: area, price: ( i+1 )*( 10 ), seats_count: 2, left_seats: 2)
      # 5.times { create(:seat, area_id: area.id) }
      2.times { create(:seat, area_id: area.id, show: @show1, price: r.price) }
    end

    seats_info = generate_seats(3, 4, Area::SEAT_AVALIABLE)
    @stadium.areas.last(3).each_with_index do |area, i|
      area.update_attributes(seats_info: seats_info)
      r = @show2.show_area_relations.create(area: area, price: ( i+1 )*( 10 ), seats_count: 12, left_seats: 12)
      # 3.times { create(:seat, area_id: area.id, show: @show2, price: r.price) }
    end

    @way = 'ios'
  end

  let(:user) { create(:user) }
  let(:areas) { @stadium.areas }
  let(:first_area) { areas.first }

  context "create_order_with_selected" do
    it "should set response to 0 when execute successfully" do
      options = { user: user, quantity: 1, area_id: first_area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show1, options)

      co_logic.execute
      expect(co_logic.order.tickets.map(&:seat_type).uniq).to eq ['locked']
      expect(co_logic.order.tickets.count).to eq 1
      expect(co_logic.response).to eq 0
      expect(co_logic.success?).to eq true
    end

    it "should set response to 1 when quantity more than left seat in that area" do
      options = { user: user, quantity: 4, area_id: first_area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show1, options)

      expect{co_logic.execute}.to change(@show1.tickets, :count).by(0)
      expect(co_logic.response).to eq 2003
      expect(co_logic.success?).to eq false
      expect(co_logic.error_msg).to eq "购买票数大于该区剩余票数!"
    end

    it "should set relation to is_sold_out when seats_count left" do
      options = { user: user, quantity: 2, area_id: first_area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show1, options)

      co_logic.execute
      expect(co_logic.response).to eq 0
      expect(co_logic.order.tickets.map(&:seat_type).uniq).to eq ['locked']
      expect(co_logic.order.tickets.count).to eq 2
      relation = ShowAreaRelation.where(show_id: @show1.id, area_id: first_area.id).first
      expect(relation.left_seats).to eq 0
      expect(relation.is_sold_out).to eq true
    end

    it "should set current order info when success" do
      options = { user: user, quantity: 2, area_id: first_area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show1, options)

      expect{co_logic.execute}.to change(user.orders, :count).by(1)
      expect(co_logic.response).to eq 0

      relation = ShowAreaRelation.where(show_id: @show1.id, area_id: first_area.id).first
      relations = []
      2.times { relations << relation }
      amount = relations.map{|relation| relation.price}.inject(&:+)

      order = co_logic.order
      expect(order.amount).to eq amount
      expect(order.show).to eq @show1
      expect(order.stadium).to eq @show1.stadium
      expect(order.stadium_name).to eq @show1.stadium.name
      expect(order.city).to eq @show1.city
      expect(order.city_name).to eq @show1.city.name
      expect(order.concert).to eq @show1.concert
      expect(order.concert_name).to eq @show1.concert.name
      expect(order.status).to eq 'pending'
    end

    it 'will handle pending_orders' do
      pending_order = user.orders.init_from_show(@show1)
      pending_order.channel = 'hoishow'
      pending_order.save
      #pending_order.create_tickets_by_relations(@show1.show_area_relations.first, 1)
      expect(pending_order.status).to eq 'pending'

      options = { user: user, quantity: 1, area_id: first_area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show1, options)

      co_logic.execute
      expect(co_logic.response).to eq 0
      expect(co_logic.success?).to eq true
      pending_order.reload
      #expect(pending_order.status).to eq 'outdate'
      expect(pending_order.tickets.count).to eq 0
    end
  end

  context "create_order_with_selectable" do
    let(:options) do
      seats = []
      @show2.areas.map do |area|
        sf = area.seats_info["seats"]
        # h[area.id.to_s] = { "1|2" => sf['1|2']['price'], "1|3" => sf['1|3']['price'] }
        seats << [area.id, 1, 2, sf['1']['2']['price']].join(':')
        seats << [area.id, 1, 3, sf['1']['3']['price']].join(':')
      end
      {
        user: user, quantity: 1, area_id: first_area.id,
        way: @way,
        seats: seats.to_json
      }
    end

    it "should set response to 0 when execute successfully" do
      co_logic = CreateOrderLogic.new(@show2, options)

      co_logic.execute
      expect(co_logic.order.tickets.count).to eq @show2.seats.count
      expect(co_logic.response).to eq 0
      expect(co_logic.success?).to eq true
      # @show2.show_area_relations.each do |r|
      #   expect(r.left_seats).to eq 0
      #   expect(r.is_sold_out).to eq true
      # end
      expect(co_logic.order.tickets.pluck(:status).uniq).to eq [0]
      @show2.areas.map do |area|
        area.reload
        sf = area.seats_info["seats"]
        expect(sf["1"]["2"]['status']).to eq Area::SEAT_LOCKED
        expect(sf["1"]["3"]['status']).to eq Area::SEAT_LOCKED
        expect(area.seats_info['selled_seats']).to eq(["1|2", "1|3"])
      end
    end

    it "should set create a new order with tickets when execute successfully" do
      co_logic = CreateOrderLogic.new(@show2, options)

      expect{co_logic.execute}.to change(user.orders, :count).by(1)
      expect(co_logic.response).to eq 0
      order = co_logic.order
      expect(order.amount).to eq @show2.seats.sum(:price)
      expect(order.show).to eq @show2
      expect(order.stadium).to eq @show2.stadium
      expect(order.stadium_name).to eq @show2.stadium.name
      expect(order.city).to eq @show2.city
      expect(order.city_name).to eq @show2.city.name
      expect(order.concert).to eq @show2.concert
      expect(order.concert_name).to eq @show2.concert.name
      expect(order.status).to eq 'pending'
    end

    it "will set response to 3 when params[:areas] was nil" do
      params = { user: user, quantity: 1, area_id: first_area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show2, params)
      expect{co_logic.execute}.to change(user.orders, :count).by(0)
      expect(co_logic.response).to eq 3014
      expect(co_logic.error_msg).to eq "缺少参数"
    end

    it "will set response to 2004 when seat was locked" do
      seats_info = generate_seats(1, 2, Area::SEAT_LOCKED)
      area = create(:area, stadium: @stadium, seats_info: seats_info)
      @show2.show_area_relations.create(area: area, seats_count: 2, left_seats: 2)
      seats = {}.tap { |h|
        sf = area.seats_info["seats"]
        h[area.id.to_s] = { "1|1" => sf['1']['1']['price'] }
      }

      params = { user: user, quantity: 1, seats: seats.to_json, area_id: area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show2, params)
      expect{co_logic.execute}.to change(user.orders, :count).by(0)
      expect(co_logic.response).to eq 2004
      expect(co_logic.error_msg).to include('存在问题')
    end

    it "will set response to 2004 when price was wrong" do
      seats_info = generate_seats(1, 2, Area::SEAT_AVALIABLE)
      area = create(:area, stadium: @stadium, seats_info: seats_info)
      @show2.show_area_relations.create(area: area, seats_count: 2, left_seats: 2)

      seats = []
      sf = area.seats_info["seats"]
      # h[area.id.to_s] = { "1|1" => -1 }
      seats << [area.id, 1, 1, -1].join(':')

      params = { user: user, quantity: 1, seats: seats.to_json, area_id: area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show2, params)
      expect{co_logic.execute}.to change(user.orders, :count).by(0)
      expect(co_logic.response).to eq 2004
      expect(co_logic.error_msg).to include('存在问题')
    end

    it "will set response to 2004 when seat was selled" do
      seats_info = generate_seats(1, 2, Area::SEAT_LOCKED, [], true, ['1|1', '1|2'])
      area = create(:area, stadium: @stadium, seats_info: seats_info)
      @show2.show_area_relations.create(area: area, seats_count: 2, left_seats: 2)

      seats = []
      sf = area.seats_info["seats"]
      # h[area.id.to_s] = { "1|1" => sf['1|1']['price'] }
      seats << [area.id, 1, 1, sf['1']['1']['price']].join(':')

      params = { user: user, quantity: 1, seats: seats.to_json, area_id: area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show2, params)
      expect{co_logic.execute}.to change(user.orders, :count).by(0)
      expect(co_logic.response).to eq 2004
      expect(co_logic.error_msg).to include('已被锁定')
    end

    # 关于 seat lock 的测试
  end
end
