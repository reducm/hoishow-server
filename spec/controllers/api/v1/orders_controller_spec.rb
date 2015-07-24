require 'rails_helper'

RSpec.describe Api::V1::OrdersController, :type => :controller do
  render_views
  before('each') do
    @user = create :user
    @concert = create :concert
    @show = create :show
    10.times {create :order, user: @user}
  end

  context "#index" do
    it "index should get 10 orders" do
      get :index, with_key(mobile: @user.mobile, api_token: @user.api_token, format: :json)
      expect(response.status).to eq 200
    end
  end

  context "#orders_for_soon" do
    it "orders_for_soon should get orders" do
      @show.update(show_time: (Time.now.tomorrow.middle_of_day))
      get :orders_for_soon, with_key(mobile: @user.mobile, api_token: @user.api_token, format: :json)
      expect(response.status).to eq 200
    end
  end

  context "#show" do
    it "show should get the same object" do
      @order = Order.first
      get :show, with_key(mobile: @user.mobile, api_token: @user.api_token, id: @order.out_id, format: :json)
      expect(assigns(:order)).to eq @order
    end
  end

  context "#show_for_qr_scan" do
    it "should return tickets" do
      @order = Order.first
      relation = create :show_area_relation
      3.times.each do |variable|
        create(:ticket, area_id: relation.area_id, show_id: relation.show_id, price: relation.price)
      end
      @order.create_tickets_by_relations(relation, 3)
      @admin = create(:admin, admin_type: 2)

      get :show_for_qr_scan, name: @admin.name, api_token: @admin.api_token, id: @order.out_id, format: :json
      expect(assigns(:order)).to eq @order
      expect(response.body).to include("tickets")
      expect(JSON.parse(response.body)["tickets"].count).to eq 3 
    end

    it "should fail if admin is not ticket-checker" do
      @order = Order.first
      3.times { create(:show_area_relation) }
      @order.set_tickets_and_price(ShowAreaRelation.all)
      @order.success_pay!
      @admin = create(:admin, admin_type: 1)

      get :show_for_qr_scan, name: @admin.name, api_token: @admin.api_token, id: @order.out_id, format: :json
      expect(response.status).to eq 403
    end
  end
end
