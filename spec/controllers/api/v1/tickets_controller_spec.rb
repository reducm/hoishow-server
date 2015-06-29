require 'rails_helper'

RSpec.describe Api::V1::TicketsController, :type => :controller do
  render_views

  context "#get_ticket" do
    it "should get the same object" do
      create :ticket
      @admin = create(:admin, admin_type: 2)
      @ticket = Ticket.first
      get :get_ticket, name: @admin.name, api_token: @admin.api_token, code: @ticket.code, format: :json
      expect(assigns(:ticket)).to eq @ticket
    end
  end

  context "#check_tickets" do
    before('each') do
      #验票员
      @admin = create(:admin, admin_type: 2)
      5.times do
        create :ticket, status: :success
      end
      @tickets = Ticket.all
      @codes = @tickets.pluck(:code).join(',')
    end

    it "should success if information correct and intact" do
      post :check_tickets, codes: @codes, name: @admin.name, api_token: @admin.api_token, format: :json
      expect(response.status).to eq 200
      expect(response.body).to include "ok"
    end

    it "should fail if ticket is used or refund" do
      @tickets.update_all(status: 2)
      @tickets.last.update(status: 3)
      post :check_tickets, codes: @codes, name: @admin.name, api_token: @admin.api_token, format: :json
      expect(response.status).to eq 403
      expect(response.body).to include "获取门票失败"
    end

    it "should fail if not getting admin" do
      post :check_tickets, codes: @codes, format: :json
      expect(response.status).to eq 403
      expect(response.body).to include "获取验票员信息异常，请重新登陆"
    end

    it "should return 406 if admin is blocked" do
      @admin.update(is_block: true)
      post :check_tickets, codes: @codes, name: @admin.name, api_token: @admin.api_token, format: :json
      expect(response.status).to eq 406
      expect(response.body).to include "账户被锁定，请联系管理员"
    end
  end
end
