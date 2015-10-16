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
      check_user_data
    end

    it "should create user fail with wrong code" do
      options = {code: "123", mobile: "18602987654", password: "123"}
      post :sign_up, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.mobile_code_not_correct")
    end
  end

  context "#sign_in" do
    before("each") do
      @user = create(:user, mobile: "18602987654")
      @user.set_password("123")
    end

    it "should sign_in success" do
      options = {mobile: "18602987654", password: "123"}
      post :sign_in, encrypted_params_in_boombox(api_key, options)
      check_user_data 
    end

    it "should sign_in fail with wrong password" do
      options = {mobile: "18602987654", password: "tom"}
      post :sign_in, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.password_not_correct")
    end

    it "should sign_in fail with wrong parameters" do
      options = {mobile: "18602987654"}
      post :sign_in, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.parameters_not_correct")
    end
  end

  context "#forgot_password" do
    before("each") do
      @user = create(:user, mobile: "18602987654")
      @user.set_password("123")
    end

    it "should change password success" do
      options = {code: "123456", mobile: "18602987654", password: "tom"}
      post :forgot_password, encrypted_params_in_boombox(api_key, options)
      check_user_data
      @user.reload
      expect(@user.password_valid?("tom")).to be true
    end

    it "should create user fail with wrong code" do
      options = {code: "123", mobile: "18602987654", password: "tom"}
      post :forgot_password, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.mobile_code_not_correct")
    end
  end

  context "#reset_password" do
    before("each") do
      @user = create(:user, mobile: "18602987654")
      @user.set_password("123")
    end

    it "should reset password success" do
      options = {current_password: "123", password: "tom", password_confirmation: "tom", api_token: @user.api_token}
      post :reset_password, encrypted_params_in_boombox(api_key, options)
      @user.reload
      expect(@user.password_valid?("tom")).to be true
      expect(json["result"]).to eq "success"
    end

    it "should reset password fail with wrong current_password" do
      options = {current_password: "ijsi", password: "tom", password_confirmation: "tom", api_token: @user.api_token}
      post :reset_password, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.current_password_not_correct")
    end

    it "should reset password fail if password blank" do
      options = {current_password: "123", password: "", password_confirmation: "tom", api_token: @user.api_token}
      post :reset_password, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.password_can_not_be_blank")
    end

    it "should reset password fail if password not same as password_confirmation" do
      options = {current_password: "123", password: "jsa", password_confirmation: "tom", api_token: @user.api_token}
      post :reset_password, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.password_can_not_confirm")
    end
  end

  context "#update_user" do
    before("each") do
      @user = create(:user)
    end

    it "update nickname success" do
      options = {api_token: @user.api_token, type: "nickname", nickname: "tom"}
      post :update_user, encrypted_params_in_boombox(api_key, options)
      check_user_data 
    end

    it "update nickname fail while nickname is blank" do
      options = {api_token: @user.api_token, type: "nickname", nickname: ""}
      post :update_user, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.nickname_not_found")
    end
  end

  context "#reset_mobile" do
    before("each") do
      @user = create(:user)
    end

    it "should reset mobile success" do
      options = {code: "123456", mobile: "18602987654", api_token: @user.api_token}
      post :reset_mobile, encrypted_params_in_boombox(api_key, options)
      check_user_data
      @user.reload
      expect(@user.mobile).to eq "18602987654"
    end

    it "should create user fail with wrong code" do
      options = {code: "56", mobile: "18602987654", api_token: @user.api_token}
      post :reset_mobile, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.mobile_code_not_correct")
    end
  end

  context "#get_user" do
    before("each") do
      @user = create(:user)
    end

    it "should reset mobile success" do
      options = {api_token: @user.api_token}
      get :get_user, encrypted_params_in_boombox(api_key, options)
      check_user_data
    end
  end



  def check_user_data
    expect(json).to include "id"
    expect(json).to include "email"
    expect(json).to include "mobile"
    expect(json).to include "avatar"
    expect(json).to include "api_token"
    expect(json).to include "nickname"
  end
end
