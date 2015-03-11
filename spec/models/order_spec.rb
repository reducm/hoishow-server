require 'spec_helper'

describe Order do
  before :each  do
    @city = create :city
    @star = create :star
    @concert = create :concert
    @stadium = create(:stadium, city: @city)
    @show = create :show, concert: @concert, stadium: @stadium
    3.times do|n|
      area =  create :area, stadium: @stadium
      @show.show_area_relations.create(area: area, price: rand(1..10))
    end
    @order = Order.init_from_data(city: @city, concert: @concert, star: @star, stadium: @stadium, show: @show)
    @order.set_seats_and_price(ShowAreaRelation.all)
  end

  context "create order" do
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
