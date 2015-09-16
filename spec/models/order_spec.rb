require 'spec_helper'

describe Order do
  before :each  do
    @user = create :user
    @city = create :city
    @concert = create :concert
    @stadium = create(:stadium, city: @city)
    @show = create :show, concert: @concert, stadium: @stadium, seat_type: 1
    3.times do|n|
      area =  create :area, stadium: @stadium
      sar = @show.show_area_relations.create(area: area, price: rand(1..10), seats_count: 2, left_seats: 2)
      # 2.times { create :avaliable_seat, show_id: @show.id, area_id: area.id, price: sar.price}
    end
    relation = @show.show_area_relations.first
    @order = @user.orders.init_and_create_tickets_by_relations(@show, {tickets_count: 2, amount: relation.price * 2}, relation)
    #@order = @user.orders.init_from_data(city: @city, concert: @concert, stadium: @stadium, show: @show)
    @order.save
    Ticket.update_all(order_id: @order.id)
    #@order.create_tickets_by_relations(ShowAreaRelation.first, 2)
  end

  context "create order" do
    it ":city, :concert, :stadium, :star, :show should be presence" do
      order = Order.new
      expect(order.valid?).to be_falsey
      Order::ASSOCIATION_ATTRS.each do|sym|
        expect(order).to have(1).error_on(sym.to_s + "_name")
      end
    end

     it "order should have out_id" do
       expect(@order.out_id.present?).to be_truthy
     end

     it "order should have valid_time" do
       expect(@order.valid_time.present?).to be_truthy
     end


    it "order should create success" do
      expect(@order.valid?).to be_truthy
    end

    # it "order amount" do
    #   result = ShowAreaRelation.all.map{|r| r.price.to_f}.inject(&:+)
    #   expect(@order.amount).to eq result
    # end

    it "Order#tickets_count" do
      expect(@order.tickets_count).to eq 2
    end

    it "new order's status should be pending" do
      expect(@order.pending?).to be true
    end
  end

  context "scope" do
    it ":valid_orders" do
      #before each has one pending_order
      3.times{  create :order }
      3.times{  create :paid_order }
      3.times{create :success_order}
      2.times{create :outdate_order}
      2.times{create :refund_order}
      expect(Order.valid_orders.count).to eq 10
    end
  end

  context "test create_order concurrency" do
    before('each') do
      @stadium = create :stadium
      10.times{create :area, stadium: @stadium}
      @show = create :show, stadium: @stadium
      Area.all.each_with_index do |area, i|
        @show.show_area_relations.create(area: area, price: ( i+1 )*( 10 ), seats_count: 2)
      end
      @user = create :user
    end

    #it "is_sold_out should be lock with multiple threads" do
      #threads = []
      #@area = Area.first
      #@relation = ShowAreaRelation.where(show_id: @show.id, area_id: @area.id).first
      #10.times do|i|
        #ap i
        #threads << Thread.new do
          #relations = [@relation, @relation]
          #ap "#{i} thread"
          #ShowAreaRelation.transaction do
            #ap "#{i} with_lok, user: #{@user}"
            #if @relation.is_sold_out
              #ap "is_sold_out"
            #else
              #@order = @user.orders.init_from_show(@show)
              #@order.set_tickets_and_price(relations)
              #@relation.reload
              #if @show.area_seats_left(@relation.area) == 0
                #@relation.update_attributes(is_sold_out: true)
              #end
            #end
            #ap "end #{i} with_lok"
          #end
        #end
      #end

      #threads.each {|t|t.join}
      #expect(Order.count).to eq 1
    #end

  end

  describe  'test for state machine' do
    let(:new_order) { create(:pending_order_with_payment, city: @city, concert: @concert,
      stadium: @stadium, show: @show, user: @user) }
    let(:payment) { new_order.payments.first }
    let(:area) { @stadium.areas.first }
    let(:sar) { ShowAreaRelation.where(show_id: @show.id, area_id: area.id).first }

    before do
      sar.update_attributes(seats_count: 3, left_seats: 3)
      # new_order买了2张票
      2.times { create :avaliable_seat, show_id: @show.id, area_id: area.id, price: sar.price, order_id: new_order.id}
      sar.update_attributes(left_seats: 1)
    end

    let(:t) { new_order.tickets.first }

    # let(:payment) { build(:payment, purchase_type: 'Order',
    #     purchase_id:  new_order.id, payment_type:  ['alipay', 'wxpay'].sample,
    #     amount: new_order.amount, paid_origin: ['ios', "android"].sample, trade_id: nil) }

    context "pre_pay" do
      it 'will set payment info after update status' do
        expect(new_order.status).to eq 'pending'
        expect(new_order.payments.to_a).not_to be_blank
        expect(payment.trade_id).to be_nil

        expect{new_order.pre_pay!({payment_type: 'alipay', trade_id: "examle_trade_no"})}
          .to change(new_order.payments, :count).by(0)
        payment.reload
        expect(payment.trade_id).to eq "examle_trade_no"
        expect(payment.status).to eq 'success'
        expect(payment.payment_type).to eq 'alipay'
        expect(payment.pay_at).not_to be_nil
        expect(new_order.reload.status).to eq 'paid'
      end
    end

    context "success_pay" do
      before do
        new_order.pre_pay!({payment_type: 'alipay', trade_id: "examle_trade_no"})
        new_order.reload
      end

      it 'will set tickets info after update status' do
        expect(new_order.status).to eq 'paid'
        expect(new_order.generate_ticket_at).to be_nil
        expect(payment.trade_id).not_to be_nil
        expect(t.status).to eq 'pending'

        new_order.success_pay!({payment: payment})
        expect(t.reload.status).to eq 'success'
        expect(new_order.generate_ticket_at).not_to be_nil
      end
    end

    context "refunds" do
      before do
        new_order.pre_pay!({payment_type: 'alipay', trade_id: "examle_trade_no"})
        new_order.success_pay!({payment: payment})
        new_order.reload
      end

      it 'will set tickets info and payment info after update status' do
        expect(new_order.status).to eq 'success'
        expect(payment.trade_id).not_to be_nil
        expect(payment.status).to eq 'success'
        expect(t.status).to eq 'success'

        new_order.refunds!({payment: payment, refund_amount: '100', handle_ticket_method: 'refund'})
        expect(t.reload.status).to eq 'pending'
        payment.reload
        expect(payment.status).to eq 'refund'
        expect(payment.refund_amount).to eq 100
        expect(payment.refund_at).not_to be_nil
      end
    end

    context 'overtime' do
      it 'selectable will set tickets info and seat info after update status' do
        seats_info = generate_seats(2, 2, Area::SEAT_AVALIABLE, [], true, ['1|1'])
        seats_info['seats']['1|1']['status'] = Area::SEAT_LOCKED
        seat1 = seats_info['seats']['1|1']

        @show.update_attributes seat_type: 0
        area =  create :area, stadium: @stadium, seats_info: seats_info
        relation2 = @show.show_area_relations.create(area: area, price: rand(1..10), seats_count: 4, left_seats: 3)
        expect(relation2.area).not_to be_nil

        o = create(:pending_order_with_payment, city: @city, concert: @concert,
          stadium: @stadium, show: @show, user: @user)

        o_ticket = create :ticket, show_id: @show.id, area_id: relation2.area_id,
          order_id: o.id, price: relation2.price, row: 1, column: 1
        expect(seat1['status']).to eq Area::SEAT_LOCKED
        expect(relation2.left_seats).to eq 3

        o.overtime!({handle_ticket_method: 'outdate'})
        # expect(sar.reload.left_seats).to eq 4
        expect(relation2.reload.left_seats).to eq 4

        sf = relation2.area.reload.seats_info
        expect(sf['seats']['1|1']['status']).to eq(Area::SEAT_AVALIABLE)
        expect(sf['selled']).to be_blank
        expect(o.reload.status).to eq 'outdate'
        expect(o_ticket.reload.status).to eq 'outdate'
      end

      it 'selected will set show_area_relation left_seats' do
        sar.update_attributes left_seats: 1
        new_order.overtime!({handle_ticket_method: 'outdate'})
        expect(sar.reload.left_seats).to eq 3
        # expect(s.map(&:status).uniq).to eq ['pending']
        expect(new_order.reload.status).to eq 'outdate'
        expect(new_order.tickets.count).to eq 0
      end

      #toDo 测试多张票和座位的情况
    end

  end
end
