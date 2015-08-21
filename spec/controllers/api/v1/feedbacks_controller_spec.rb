require 'rails_helper'

RSpec.describe Api::V1::FeedbacksController, :type => :controller do
  context "#create" do
    it "should create feedback success" do
      post :create, with_key(content: 'hello, world', mobile: '13888888888', format: :json)
      expect(response.status).to eq 200
      expect(response.body).to include 'ok'
    end

    it "should create feedback fail without params" do
      post :create, with_key(content: 'hello, world', format: :json)
      expect(response.status).to eq 403
      expect(response.body).to include '反馈内容/联系方式不能为空'
    end
  end
end
