require 'spec_helper'

describe Api::V1::UsersController do
  render_views
  context "#verification" do
     it "users sholud has code" do
       mobile = "13632269944"
       post :verification, with_key( mobile: mobile )
       expect(response.status).to eq 200
       expect(Rails.cache.read(controller.send("cache_key", mobile)).present?).to be_truthy
     end

     it "wrong mobile should be forbit" do
       post :verification, with_key( mobile: "123", format: :json)
       expect(response.status).to eq 403
       expect( response.body ).to include "errors"
     end

     it "post twice sholud be forbit" do
       mobile = "13632269944"
       post :verification, with_key( mobile: mobile)
       expect(response.status).to eq 200
       post :verification, with_key( mobile: mobile)
       expect(response.status).to eq 403
       expect( response.body ).to include "errors"
     end

  end

  context "#sign_in" do
    it "post right mobile and code should return users infomation" do
       mobile = "13632269944"
       post :verification, with_key( mobile: mobile)
       code = Rails.cache.read(controller.send("cache_key", mobile))

       post :sign_in, with_key(mobile: mobile, code: code, format: :json)
       expect(assigns(:user).valid?).to be_truthy
       expect(assigns(:user).mobile).to eq mobile  
       expect(assigns(:user).api_token.present?).to eq true
       expect(Rails.cache.read(controller.send("cache_key", mobile)).blank?).to eq true
       expect(response.status).to eq 200
       expect(response.body).to include "api_token"
       expect(response.body).to include "expires_in"
       expect(response.body).to include "mobile"
       expect(response.body).to include "nickname"
       expect(response.body).to include "avatar"
    end
    
    it "wrong code should be forbit"do
      mobile = "13632269944"
      post :verification, with_key( mobile: mobile)
      code = Rails.cache.read(controller.send("cache_key", mobile))
      post :sign_in, with_key(mobile: mobile, code: "1", format: :json)
      expect(response.status).to eq 403
      expect(response.body).to include("验证码错误")
    end

  end

  context "#update_user" do
  end
end
