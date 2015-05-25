require 'rails_helper'

RSpec.describe Operation::ConcertsController, :type => :controller do
  render_views
  before('each') do
    admin = create :admin
    login(admin)
  end

  context "#index" do
    before('each') do
      5.times do
        create :concert
      end
    end

    it "should get 5 concerts" do
      get :index
      expect(assigns(:concerts).size).to eq 5
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

    it "saves the new concert in the database" do
      expect{
        post :create, concert: attributes_for(:concert), star_id: 1
      }.to change(Concert, :count).by(1)
    end

    it "saves the new message in the database" do
      expect{
        post :create, concert: attributes_for(:concert), star_id: 1
      }.to change(Message, :count).by(1)
    end
  end

end
