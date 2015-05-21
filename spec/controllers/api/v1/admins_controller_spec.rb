require 'spec_helper'

describe Api::V1::AdminsController do
  render_views

  context "#sign_in" do
    it "post right name and password should return admin infomation" do
      admin = Admin.new(name: "ooxx", admin_type: 2)
      admin.set_password("123456")
      admin.save

      post :sign_in, name: admin.name, password: "123456", format: :json
      expect(response.status).to eq 200
      expect(response.body).to include "id"
      expect(response.body).to include "email"
      expect(response.body).to include "name"
      expect(response.body).to include "admin_type"
      expect(response.body).to include "last_sign_in_at"
    end

    it "wrong name/password combination should be forbit"do
      post :sign_in, name: "ooo", password: "xxx", format: :json
      expect(response.status).to eq 403
      expect(response.body).to include("账号或密码错误")
    end

    it "wrong admin_type should be forbit" do
      admin = Admin.new(name: "ox", admin_type: 1)
      admin.set_password("123")
      admin.save

      post :sign_in, name: admin.name, password: "123", format: :json
      expect(response.status).to eq 403
      expect(response.body).to include("账户无验票权限")
    end
  end

  context "#check_tickets" do
    it "should success if information correct and intact" do
      5.times do
        create :ticket
      end 
      tickets = Ticket.all
      codes = tickets.pluck(:code)
      admin = Admin.new(name: "ooxx", admin_type: 2)
      admin.set_password("123456")
      admin.save

      patch :check_tickets, codes: codes, admin_id: admin.id, format: :json 
      expect(response.status).to eq 200 
      expect(response.body).to include "ok"
    end

    it "should fail if ticket is used or refund" do
      5.times do
        create :ticket
      end 
      tickets = Ticket.all
      tickets.update_all(status: 2)
      tickets.last.update(status: 3)
      codes = tickets.pluck(:code)
      admin = Admin.new(name: "ooxx", admin_type: 2)
      admin.set_password("123456")
      admin.save

      patch :check_tickets, codes: codes, admin_id: admin.id, format: :json 
      expect(response.status).to eq 403 
      expect(response.body).to include "门票已使用或已过期"
    end

    it "should fail if not getting admin" do
      5.times do
        create :ticket
      end 
      tickets = Ticket.all
      codes = tickets.pluck(:code)

      patch :check_tickets, codes: codes, admin_id: 2, format: :json 
      expect(response.status).to eq 403 
      expect(response.body).to include "获取验票员信息异常，请重新登陆"
    end
  end

end
