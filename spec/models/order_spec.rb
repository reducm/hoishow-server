require 'spec_helper'

describe Order do
  before :each  do
    @user = create :user
    @city = create :city
    @district = create :district, city: @city
    @concert = create :concert
    @stadium = create(:stadium, district: @district)
    @show = create :show, concert: @concert, stadium: @stadium
    3.times do|n|
      area =  create :area, stadium: @stadium
      @show.show_area_relations.create(area: area, price: rand(1..10))
    end
    @order = @user.orders.init_from_data(city: @city, concert: @concert, stadium: @stadium, show: @show)
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
end
