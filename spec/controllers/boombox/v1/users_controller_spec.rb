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

    it "update nickname fail while email format is wrong" do
      options = {api_token: @user.api_token, type: "email", email: @user.email}
      post :update_user, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.email_format_wrong")
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

  context "#followed_collaborators" do
    before("each") do
      @user = create(:user)
      10.times do
        collaborator = create :collaborator
        @user.follow_collaborator(collaborator)
      end
    end

    it "should get 10 Collaborator" do
      options = {api_token: @user.api_token}
      get :followed_collaborators, encrypted_params_in_boombox(api_key, options)
      expect(json[0]).to include "id"
      expect(json[0]).to include "name"
      expect(json[0]).to include "email"
      expect(json[0]).to include "contact"
      expect(json[0]).to include "weibo"
      expect(json[0]).to include "wechat"
      expect(json[0]).to include "cover"
      expect(json[0]).to include "description"
      expect(json.is_a? Array).to be true
      expect(json.size).to eq 10
    end
  end

  context "#followed_playlists" do
    before("each") do
      @user = create(:user)
      10.times do
        @user.follow_boomplaylist(create(:boom_playlist))
      end
    end

    it "should get 10 playlist" do
      options = {api_token: @user.api_token}
      get :followed_playlists, encrypted_params_in_boombox(api_key, options)
      expect(json[0]).to include "id"
      expect(json[0]).to include "name"
      expect(json[0]).to include "tracks"
      expect(json.is_a? Array).to be true
      expect(json.size).to eq 10
    end
  end

  context "#my_playlists" do
    before("each") do
      @user = create(:user)
      10.times do |n|
        create(:boom_playlist, name: n.to_s)
      end
    end

    it "should get 10 playlist" do
      options = {api_token: @user.api_token}
      get :my_playlists, encrypted_params_in_boombox(api_key, options)
      expect(json[0]).to include "id"
      expect(json[0]).to include "name"
      expect(json[0]).to include "tracks"
      expect(json.is_a? Array).to be true
      expect(json.size).to eq 10
    end
  end

  context "#comment_list" do
    before("each") do
      @user = create(:user)
      3.times do |n|
        user = create :user
        comment = create(:boom_comment, content: n.to_s, creator_id: @user.id)
        create(:boom_comment, content: ( n+10 ).to_s, parent_id: comment.id, creator_id: user.id)
      end
    end

    it "should get comments" do
      options = {api_token: @user.api_token}
      get :comment_list, encrypted_params_in_boombox(api_key, options)
      expect(json[0]).to include "id"
      expect(json[0]).to include "content"
      expect(json[0]).to include "created_at"
      expect(json[0]).to include "avatar"
      expect(json[0]).to include "created_by"
      expect(json[0]).to include "parent"
      expect(json.is_a? Array).to be true
    end
  end

  context "#follow_subject" do
    before("each") do
      @user = create(:user)
      10.times {create :collaborator}
    end

    it "should follow Collaborator success" do
      options = {api_token: @user.api_token, subject_type: "Collaborator", subject_id: Collaborator.first.id}
      post :follow_subject, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end

    it "should follow fail while subject_type not right" do
      options = {api_token: @user.api_token, subject_type: "Star", subject_id: Collaborator.first.id}
      post :follow_subject, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.subject_type_not_correct")
    end

    it "should follow fail while subject_id not right" do
      options = {api_token: @user.api_token, subject_type: "Collaborator", subject_id: 999}
      post :follow_subject, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.subject_not_found")
    end
  end

  context "#unfollow_subject" do
    before("each") do
      @user = create(:user)
      10.times {create :collaborator}
      @user.follow_collaborator(Collaborator.first)
    end

    it "should unfollow Collaborator success" do
      options = {api_token: @user.api_token, subject_type: "Collaborator", subject_id: Collaborator.first.id}
      post :unfollow_subject, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end
  end

  context "#create_comment" do
    before("each") do
      @user = create(:user)
      @topic = create(:boom_topic)
      @comment = create(:boom_comment)
    end

    it "should create comment success" do
      options = {api_token: @user.api_token, creator_type: "User", creator_id: @user.id, topic_id: @topic.id, content: "ahskjdhaksd", parent_id: @comment.id}
      post :create_comment, encrypted_params_in_boombox(api_key, options)
      expect(json).to include "id"
      expect(json).to include "content"
      expect(json).to include "created_at"
      expect(json).to include "avatar"
      expect(json).to include "created_by"
      expect(json).to include "parent"
      expect(json.is_a? Array).to be false
    end
  end

  context "#like_subject" do
    before("each") do
      @user = create(:user)
      @topic = create(:boom_topic)
      @comment = create(:boom_comment)
    end

    it "should like topic success" do
      options = {api_token: @user.api_token, subject_type: "BoomTopic", subject_id: @topic.id}
      post :like_subject, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end

    it "should like comment success" do
      options = {api_token: @user.api_token, subject_type: "BoomComment", subject_id: @comment.id}
      post :like_subject, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end
  end

  context "#unlike_subject" do
    before("each") do
      @user = create(:user)
      @topic = create(:boom_topic)
      @comment = create(:boom_comment)
    end

    it "should unlike topic success" do
      @user.like_boomtopic(@topic)
      options = {api_token: @user.api_token, subject_type: "BoomTopic", subject_id: @topic.id}
      post :unlike_subject, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end

    it "should unlike comment success" do
      @user.like_boomtopic(@comment)
      options = {api_token: @user.api_token, subject_type: "BoomTopic", subject_id: @comment.id}
      post :unlike_subject, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end
  end

  context "#add_to_playlist" do
    before("each") do
      @user = create(:user)
      @playlist = create(:boom_playlist)
      @track = create(:boom_track)
    end

    it "should add track to playlist success" do
      options = {api_token: @user.api_token, playlist_id: @playlist.id, track_id: @track.id}
      post :add_to_playlist, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end

    it "should add track to playlist fail while playlist_id is wrong" do
      options = {api_token: @user.api_token, playlist_id: 999, track_id: @track.id}
      post :add_to_playlist, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.playlist_not_found")
    end
  end

  context "#delete_track_from_playlist" do
    before("each") do
      @user = create(:user)
      @playlist = create(:boom_playlist)
      @track = create(:boom_track)
      @playlist.playlist_track_relations.where(boom_track_id: @track.id).first_or_create!
    end

    it "should delete track from playlist success" do
      options = {api_token: @user.api_token, playlist_id: @playlist.id, track_id: @track.id}
      post :delete_track_from_playlist, encrypted_params_in_boombox(api_key, options)
      expect(json["result"]).to eq "success"
    end

    it "should delete track from playlist fail while track_id is wrong" do
      options = {api_token: @user.api_token, playlist_id: @playlist.id, track_id: 999}
      post :delete_track_from_playlist, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.track_not_found")
    end
  end

  context "#create_playlist" do
    before("each") do
      @user = create(:user)
    end

    it "should get 1 playlist" do
      name = "tom"
      options = {api_token: @user.api_token, name: name}
      post :create_playlist, encrypted_params_in_boombox(api_key, options)
      expect(json).to include "id"
      expect(json).to include "name"
      expect(json).to include "tracks"
      expect(json.is_a? Array).to be false
      expect(json["name"]).to eq name
    end

    it "should create playlist fail while name blank" do
      options = {api_token: @user.api_token, name: ""}
      post :create_playlist, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.playlist_name_can_not_blank")
    end
  end

  context "#delete_playlist" do
    before("each") do
      @user = create(:user)
      @playlist = create(:boom_playlist)
    end

    it "should delete 1 playlist" do
      options = {api_token: @user.api_token, playlist_id: @playlist.id}
      expect {
        post :delete_playlist, encrypted_params_in_boombox(api_key, options)
      }.to change(BoomPlaylist, :count).by(-1)
      expect(json["result"]).to eq "success"
    end

    it "should delete playlist fail while playlist blank" do
      options = {api_token: @user.api_token}
      post :delete_playlist, encrypted_params_in_boombox(api_key, options)
      expect(json["errors"]).to eq I18n.t("errors.messages.parameters_not_correct")
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
