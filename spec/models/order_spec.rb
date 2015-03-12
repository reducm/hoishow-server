require 'spec_helper'

describe Order do
  before :each  do
    @user = create :user
    @city = create :city
    @star = create :star
    @concert = create :concert
    @stadium = create(:stadium, city: @city)
    @show = create :show, concert: @concert, stadium: @stadium
    3.times do|n|
      area =  create :area, stadium: @stadium
      @show.show_area_relations.create(area: area, price: rand(1..10))
    end
    @order = @user.orders.init_from_data(city: @city, concert: @concert, star: @star, stadium: @stadium, show: @show)
    @order.set_seats_and_price(ShowAreaRelation.all)
  end

  context "create order" do
    it ":city, :concert, :stadium, :star, :show should be presence" do
      order = Order.new 
      expect(order.valid?).to be_false
      Order::ASSOCIATION_ATTRS.each do|sym|
        expect(order).to have(1).error_on(sym.to_s + "_name")
      end
    end

     it "order should have out_id" do
       expect(@order.out_id.present?).to be_true
     end

     it "order should have valid_time" do
       expect(@order.valid_time.present?).to be_true
     end


    it "order should create success" do
      expect(@order.valid?).to be_true 
    end

    it "order amount" do
      result = ShowAreaRelation.all.map{|r| r.price.to_f}.inject(&:+)
      expect(@order.amount).to eq result
    end

    it "Order#seats_count" do
      expect(@order.seats_count).to eq ShowAreaRelation.all.size
    end
  end
end
