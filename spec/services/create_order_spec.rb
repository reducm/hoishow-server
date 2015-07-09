require 'spec_helper'

describe CreateOrderLogic do
  before(:each) do
    @stadium = create(:stadium)
    @show1 = create(:show, stadium: @stadium, seat_type: Show.seat_types[:selected])
    @show2 = create(:show, stadium: @stadium, seat_type: Show.seat_types[:selectable])

    5.times{ create(:area, stadium: @stadium) }
    @stadium.areas.first(2).each_with_index do |area, i|
      @show1.show_area_relations.create(area: area, price: ( i+1 )*( 10 ), seats_count: 2)
      # 5.times { create(:seat, area_id: area.id) }
    end

    @stadium.areas.last(3).each_with_index do |area, i|
      @show2.show_area_relations.create(area: area, price: ( i+1 )*( 10 ), seats_count: 2)
      3.times { create(:seat, area_id: area.id, show: @show2) }
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

      expect{co_logic.execute}.to change(@show1.tickets, :count).by(1)
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

      expect{co_logic.execute}.to change(@show1.tickets, :count).by(2)
      expect(co_logic.response).to eq 0
      relation = ShowAreaRelation.where(show_id: @show1.id, area_id: first_area.id).first
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
      pending_order.channel = 'ios'
      pending_order.save
      pending_order.create_tickets_by_relations([@show1.show_area_relations.first])
      expect(pending_order.status).to eq 'pending'

      options = { user: user, quantity: 1, area_id: first_area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show1, options)

      expect{co_logic.execute}.to change(@show1.tickets, :count).by(1)
      expect(co_logic.response).to eq 0
      expect(co_logic.success?).to eq true
      pending_order.reload
      expect(pending_order.status).to eq 'outdate'
      expect(pending_order.tickets.first.status).to eq 'outdate'
    end
  end

  context "create_order_with_selectable" do
    let(:options) do
      {
        user: user, quantity: 1, area_id: first_area.id,
        way: @way,
        areas: @show2.areas.map do |area|
          {
            area_id: area.id,
            seats: area.seats.map do |s|
              { id: s.id, seat_no: s.name }
            end
          }
        end.to_json
      }
    end

    it "should set response to 0 when execute successfully" do
      co_logic = CreateOrderLogic.new(@show2, options)

      expect{co_logic.execute}.to change(@show2.tickets, :count).by(@show2.seats.count)
      expect(co_logic.response).to eq 0
      expect(co_logic.success?).to eq true
      # expect(co_logic.order.tickets.pluck(:status).uniq).to eq [0]
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

      expect(order.tickets.count).to eq @show2.seats.count
    end

    it "will set response to 3 when params[:areas] was nil" do
      params = { user: user, quantity: 1, area_id: first_area.id, way: @way }
      co_logic = CreateOrderLogic.new(@show2, params)
      expect{co_logic.execute}.to change(user.orders, :count).by(0)
      expect(co_logic.response).to eq 3
      expect(co_logic.error_msg).to eq "不能提交空订单"
    end

    # 关于 seat lock 的测试
  end
end
