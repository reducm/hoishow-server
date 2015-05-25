require 'rails_helper'

RSpec.describe Api::V1::MessagesController, :type => :controller do
  render_views
  before('each') do
    2.times { create :reply_message }
    5.times { create :system_message }
    @user = create :user
    @topic = create :topic
    @star = create :star
  end

  context "#index" do
    it "should get  messages" do
      get :index, with_key(type: "system", mobile: @user.mobile, api_token: @user.api_token, format: :json)
      binding.pry
      expect(JSON.parse(response.body).size).to eq 5 
    end
  end
end
