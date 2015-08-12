require 'rails_helper'

RSpec.describe Operation::AdminsController, :type => :controller do
  render_views
  before('each') do
    admin = create :admin
    login(admin)
  end

  context "#index " do
    before('each') do
      5.times do
        create :admin
        create :operator
        create :ticket_checker
      end
    end

    it "should get 16 admins" do
      get :index
      expect(assigns(:admins).size).to eq 16
      expect(response).to render_template :index
    end
  end

  context "#create" do
    it "add new admin" do
      expect {
        post :create, username: 'xxx', password: 'xxx', admin_type: 0
      }.to change(Admin, :count).by(1)
    end
  end

end
