require 'rails_helper'

RSpec.describe Operation::StadiumsController, :type => :controller do
  render_views

  before('each') do
    @admin = create(:admin)
    @city = create(:city)
    login(@admin)

    30.times do |i|
      create(:stadium, city: @city)
    end
  end

  context '#index' do
    it "should get 10 stadiums" do
      get :index, city_id: @city.id
      expect(assigns(:stadiums).size).to eq 30
      expect(response).to render_template("index")
    end
  end
end