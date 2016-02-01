require 'rails_helper'

RSpec.describe Boombox::V1::FeedbacksController, :type => :controller do
  include BoomboxInitHelper

  context "#create" do
    it "should create feedback success" do
      options = {content: 'hello, world', contact: '13888888888'}
      post :create, encrypted_params_in_boombox(api_key, options)
      expect(response.status).to eq 200
      expect(response.body).to include 'ok'
    end

    it "should create feedback fail without content" do
      options = {content: '', contact: '13888888888'}
      post :create, encrypted_params_in_boombox(api_key, options)
      expect(response.status).to eq 403
      expect(response.body).to include '反馈内容不能为空'
    end
  end
end
