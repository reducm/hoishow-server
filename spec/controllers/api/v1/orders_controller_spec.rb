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

  context "#show" do
    it "show should get the same object" do
      @order = Order.first
      get :show, with_key(mobile: @user.mobile, api_token: @user.api_token, id: @order.out_id, format: :json)
      expect(assigns(:order)).to eq @order
    end
  end
end
