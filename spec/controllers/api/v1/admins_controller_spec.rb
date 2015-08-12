require 'spec_helper'

describe Api::V1::AdminsController do
  render_views

  context "#sign_in" do
    it "post right name and password should return admin infomation" do
      admin = Admin.create(name: "桐生一马", admin_type: 2)
      admin.set_password("123456")
      admin.save
      
      post :sign_in, name: admin.name, password: "123456", format: :json
      expect(response.status).to eq 200
      expect(response.body).to include "id"
      expect(response.body).to include "email"
      expect(response.body).to include "name"
      expect(response.body).to include "api_token"
      expect(response.body).to include "admin_type"
      expect(response.body).to include "last_sign_in_at"
    end

    it "wrong name/password combination should be forbit"do
      post :sign_in, name: "ooxx", password: "xxx", format: :json
      expect(response.status).to eq 403
      expect(response.body).to include("账户或密码错误")
    end
  end
end
