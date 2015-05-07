require 'spec_helper'

describe Order do
  before :each  do
    @user = create :user
    @city = create :city
    @concert = create :concert
    @stadium = create(:stadium, city: @city)
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
end
