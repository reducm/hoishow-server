require 'rails_helper'

RSpec.describe Operation::TicketsController, :type => :controller do
  render_views

  context "#index" do
    before('each') do
      admin = create :admin
      session[:admin_id] = admin.id
      30.times do |i|
        create(:ticket, code: i)
      end
    end

    it "should get 20 (base on model paginates_per) shows" do
      get :index
      binding.pry
    end

  end
end
