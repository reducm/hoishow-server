require 'rails_helper'

RSpec.describe Api::V1::MessagesController, :type => :controller do
  render_views
  before('each') do
    @user = create :user
    @topic = create :topic
    @star = create :star
    2.times do |message|
      message = create :reply_message 
      message.create_relation_with_users([@user])
    end   
    5.times do |message|
      message = create :system_message 
      message.create_relation_with_users([@user])
    end
  end

  context "#index" do
    it "should get five system messages" do
      get :index, with_key(type: "system", mobile: @user.mobile, api_token: @user.api_token, format: :json)
      expect(JSON.parse(response.body).size).to eq 5 
    end
    it "should get two reply messages" do
      get :index, with_key(type: "reply", mobile: @user.mobile, api_token: @user.api_token, format: :json)
      expect(JSON.parse(response.body).size).to eq 2 
    end
    it "is_new should be true" do
      get :index, with_key(type: "reply", mobile: @user.mobile, api_token: @user.api_token, format: :json)
      expect(JSON.parse(response.body).first["is_new"]).to eq true 
    end
    it "should set send_log is_new false after request" do
      message = create :reply_message 
      message.create_relation_with_users([@user])
      send_log = UserMessageRelation.last
      get :index, with_key(type: "reply", mobile: @user.mobile, api_token: @user.api_token, format: :json)
      expect(JSON.parse(response.body).first["is_new"]).to eq true 
      send_log.reload
      expect(send_log.is_new).to eq false
    end
    it "should render correct msg if has new messages" do
      get :index, with_key(type: "all", mobile: @user.mobile, api_token: @user.api_token, format: :json)
      expect(response.body).to eq "{\"msg\":\"yes\"}"
    end
    it "should render correct msg if no new messages" do
      UserMessageRelation.update_all(is_new: false)
      get :index, with_key(type: "all", mobile: @user.mobile, api_token: @user.api_token, format: :json)
      expect(response.body).to eq "{\"msg\":\"no\"}"
    end
  end
end
