require 'rails_helper'

RSpec.describe Boombox::V1::UsersController, :type => :controller do
  include BoomboxInitHelper

  context "#verification" do
    it "should get success" do
      options = {mobile: "18602987654"}
      get :verification, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end
  end

  context "#verified_mobile" do
    it "should get mobile_not_right message" do
      options = {mobile: "110"}
      get :verified_mobile, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.mobile_not_right")
    end

    it "verified_mobile should success and is_member should be false" do
      mobile = "15934567890"
      options = {mobile: mobile}
      get :verified_mobile, encrypted_params_in_boombox(api_key, options)
      expect(json["is_member"]).to be false
      expect(json["mobile"]).to eq mobile
    end

    it "verified_mobile should success and is_member should be true" do
      mobile = "15934567890"
      user = create(:user, mobile: mobile)
      options = {mobile: mobile}
      get :verified_mobile, encrypted_params_in_boombox(api_key, options)
      expect(json["is_member"]).to be true 
      expect(json["mobile"]).to eq user.mobile
    end
  end

  context "#sign_up" do
    it "should create user success" do
      options = {code: "123456", mobile: "18602987654", password: "123"}
      post :sign_up, encrypted_params_in_boombox(api_key, options)
      expect(json).to include "id"
      expect(json).to include "email"
      expect(json).to include "mobile"
      expect(json).to include "avatar"
      expect(json).to include "api_token"
      expect(json).to include "nickname"
    end

    it "should create user fail with wrong code" do
      options = {code: "123", mobile: "18602987654", password: "123"}
      post :sign_up, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.mobile_code_not_correct")
    end
  end

  context "#update_user" do
    before("each") do
      @test_user = create(:user)
    end

    it "update nickname success" do
      options = {api_token: @test_user.api_token, type: "nickname", nickname: "tom"}
      post :update_user, encrypted_params_in_boombox(api_key, options)
      expect(json).to include "id"
      expect(json).to include "email"
      expect(json).to include "mobile"
      expect(json).to include "avatar"
      expect(json).to include "api_token"
      expect(json).to include "nickname"
    end

    it "update nickname fail while nickname is blank" do
      options = {api_token: @test_user.api_token, type: "nickname", nickname: ""}
      post :update_user, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.nickname_not_found")
    end
  end

end
