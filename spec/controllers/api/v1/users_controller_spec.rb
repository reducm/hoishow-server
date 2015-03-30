require 'spec_helper'

describe Api::V1::UsersController do
  render_views
  before('each') do
    @user = create :user
  end
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

    it "phone format should be correct" do
      mobile = "13632269944"
      post :verification, with_key( mobile: mobile)
      code = Rails.cache.read(controller.send("cache_key", mobile))

      post :sign_in, with_key(mobile: "1102asdfa", code: code, format: :json)
      expect(response.status).to eq 403
      expect(response.body).to include("手机格式不对")
    end

    it "wrong argument should be forbit" do
      post :sign_in, with_key()
      expect(response.status).to eq 403
      expect(response.body).to include("传递参数出现不匹配")
    end
  end

  context "#update_user" do
    it "type avatar" do
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "avatar", avatar: fixture_file_upload("/about.png", "image/png"), format: :json )
      expect(response.status).to eq 200
      expect( (JSON.parse response.body)["avatar"].is_a?(String) ).to be true
    end

    it "type avatar error" do
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "avatar" )
      expect(response.status).to eq 403
      expect(response.body).to include "avatar"
    end

    it "type nickname" do
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "nickname", nickname: "tom", format: :json )
      expect(response.status).to eq 200
      @user.reload
      expect(@user.nickname).to eq "tom"
      expect( (JSON.parse response.body)["nickname"].blank?).to be false
    end

    it "type nickname is blank" do
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "nickname" )
      expect(response.status).to eq 403
      expect( (JSON.parse response.body)["nickname"].blank?).to be true
    end

    it "type sex" do
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "sex", sex: "male", format: :json )
      expect(response.status).to eq 200
      expect( (JSON.parse response.body)["sex"] ).to eq "male"
    end

    it "type sex is blank" do
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "sex",  format: :json )
      expect(response.status).to eq 403
      expect( (JSON.parse response.body)["sex"].blank? ).to be true
    end

    it "type sex is error" do
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "sex", sex: "2a", format: :json )
      expect(response.status).to eq 403
      expect(response.body).to include "sex"
    end

    it "type birthday" do
      time = "1426844347962"
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "birthday", birthday: time, format: :json )
      expect(response.status).to eq 200
      expect((JSON.parse response.body)["birthday"].blank?).to be false  
      @user.reload
      expect(@user.birthday.strftime("%Y-%m-%d")).to eq Time.from_ms(time).strftime("%Y-%m-%d")
    end


    it "type birthday is blank" do
      post :update_user, with_key( api_token: @user.api_token, mobile: @user.mobile, type: "birthday",  format: :json )
      expect(response.status).to eq 403
      expect( (JSON.parse response.body)["birthday"].blank? ).to be true
    end



  end

  context "#get_user" do
    it "get_user should success" do
      post :get_user, with_key( api_token: @user.api_token, mobile: @user.mobile, format: :json )
      expect(response.status).to eq 200
      expect(response.body).to include "nickname"
      expect(response.body).to include "mobile"
      expect(response.body).to include "api_token"
      expect(response.body).to include "api_expires_in"
      expect(response.body).to include "sex"
      expect(response.body).to include "birthday"
    end
  end

  context "#follow_subject" do
    it "should follow star success" do 
      @star = create(:star)
      post :follow_subject, with_key( api_token: @user.api_token, mobile: @user.mobile, subject_type: "Star", subject_id: @star.id, format: :json )
      @user.reload
      expect(@user.follow_stars.size > 0).to be true
    end

    it "should follow concert success" do 
      @concert = create(:concert)
      post :follow_subject, with_key( api_token: @user.api_token, mobile: @user.mobile, subject_type: "Concert", subject_id: @concert.id, format: :json )
      @user.reload
      expect(@user.follow_concerts.size > 0).to be true
    end

    it "wrong subject_type should return 403" do 
      @star = create :star
      post :follow_subject, with_key( api_token: @user.api_token, mobile: @user.mobile, subject_type: "star", subject_id: @star.id, format: :json )
      expect(response.status).to eq 403 
    end

    it "wrong subject_id should return 403" do 
      post :follow_subject, with_key( api_token: @user.api_token, mobile: @user.mobile, subject_type: "Star", subject_id: "abc", format: :json )
      expect(response.status).to eq 403 
    end

  end

  context "#vote_concert" do
    it "should vote concert success" do
      @concert = create(:concert)
      @city = create(:city)
      post :vote_concert, with_key( api_token: @user.api_token, mobile: @user.mobile, concert_id: @concert.id, city_id: @city.id, format: :json )
      @user.reload
      expect(response.status).to eq 200
      expect(@user.vote_concerts.size > 0).to be true
      expect(@user.user_vote_concerts.first.city.present?).to be true
    end
  end

end
