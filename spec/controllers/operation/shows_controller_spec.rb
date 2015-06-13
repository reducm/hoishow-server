require 'rails_helper'

RSpec.describe Operation::ShowsController, :type => :controller do
  render_views
  before('each') do
    admin = create :admin
    login(admin)
  end

  context "#index " do
    before('each') do
      5.times do
        create :show
      end
    end

    it "should get 5 shows" do
      get :index
      expect(assigns(:shows).size).to eq 5
      expect(response).to render_template :index
    end
  end

  context "#create" do
    before('each') do
      star = create :star
      @concert = create :concert
      star.hoi_concert(@concert)
      user = create :user
      @city = create :city
      @stadium = create :stadium
      user.follow_star(star)
      user.vote_concert(@concert, @city)
      user.follow_concert(@concert)
    end

    it "saves the new show in the database" do
      expect {
        post :create, show: attributes_for(:show, concert_id: @concert.id, city_id: @city.id, stadium_id: @stadium.id)
      }.to change(Show, :count).by(1)
    end
  end

  context "#update_status" do
    before('each') do
      star = create :star
      concert = create :concert
      city = create :city
      star.hoi_concert(concert)
      @show = create :show, concert: concert, city: city
      user = create :user
      user.follow_star(star)
      user.vote_concert(concert, city)
      user.follow_concert(concert)
      user.follow_show(@show)
    end

    it "saves the new show in the database" do
      expect {
        post :update_mode, id: @show
      }.to change(Message, :count).by(1)
    end
  end

end
