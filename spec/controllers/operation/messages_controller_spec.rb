require 'rails_helper'

RSpec.describe Operation::MessagesController, :type => :controller do
  render_views
  before('each') do
    admin = create :admin
    login(admin)
  end

  context "#index " do
    before('each') do
      5.times do
        create :message
      end
    end

    it "should get 5 messages" do
      get :index
      expect(assigns(:messages).size).to eq 5
      expect(response).to render_template :index
    end
  end

  context "#create" do
    before('each') do
      star = create :star
      show = create :show
      user = create :user
      user.follow_star(star)
    end
    it "add new message" do
      expect {
        post :create, message: attributes_for(:message, creator_type:"Star", subject_type: "Star", send_type:"new_show", creator_id:1, subject_id:1)
      }.to change(Message, :count).by(1)
    end
  end


end
