require 'rails_helper'

RSpec.describe Operation::TicketsController, :type => :controller do
  render_views
  before('each') do
    admin = create :admin
    login(admin)
    30.times do |i|
      create(:used_ticket, code: i)
    end
  end


  context "#index" do
    it "should get 20 (base on model paginates_per) tickets" do
      get :index
      expect(assigns(:tickets).size).to eq 30
      expect(response).to render_template :index
    end

  end
end
