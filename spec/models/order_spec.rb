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
      @show.show_area_relations.create(area: area, price: rand(1..10), seats_count: 2, left_seats: 2)
    end
    @order = @user.orders.init_from_data(city: @city, concert: @concert, stadium: @stadium, show: @show)
    @order.save
    @order.set_tickets_and_price(ShowAreaRelation.all)
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

    it "order amount" do
      result = ShowAreaRelation.all.map{|r| r.price.to_f}.inject(&:+)
      expect(@order.amount).to eq result
    end

    it "Order#tickets_count" do
      expect(@order.tickets_count).to eq ShowAreaRelation.all.size
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
    let(:sar) { ShowAreaRelation.where(show_id: @show.id, area_id: area.id).all }

    before do
      new_order.set_tickets_and_price(sar)
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

        new_order.refunds!({payment: payment, refund_amount: '100'})
        expect(t.reload.status).to eq 'refund'
        payment.reload
        expect(payment.status).to eq 'refund'
        expect(payment.refund_amount).to eq 100
        expect(payment.refund_at).not_to be_nil
      end
    end

    context 'overtime' do
      it 'selectable will set tickets info and seat info after update status' do
        @show.update_attributes seat_type: 0
        @seat = area.seats.create
        @seat.update_attributes(status: :locked, order_id: new_order.id)
        expect(@seat.status).to eq 'locked'

        new_order.overtime!
        expect(@seat.reload.status).to eq 'avaliable'
        expect(t.reload.status).to eq 'outdate'
      end

      it 'selected will set show_area_relation left_seats' do
        sar[0].update_attributes left_seats: 1
        new_order.overtime!
        expect(sar[0].reload.left_seats).to eq 2
        expect(t.reload.status).to eq 'outdate'
      end

      #toDo 测试多张票和座位的情况
    end

  end
end
