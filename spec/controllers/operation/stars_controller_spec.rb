require 'rails_helper'

RSpec.describe Operation::StarsController, :type => :controller do
  describe 'GET #show' do
    before :each do
      admin = create :admin
      session[:admin_id] = admin.id
      @star = create(:star)
    end
    it "assigns the requested star to @star" do
      get :show, id: @star
      expect(assigns(:star)).to eq @star
    end

    it "renders the :show template" do 
      get :show, id: @star
      expect(response).to render_template :show 
    end

    it "should get star's concerts if exist" do
      concert = create(:concert)
      @star.hoi_concert(concert)
      get :show, id: @star
      expect(@star.concerts.first).to eq concert 
    end

    it "should paginate star's concerts if exist" do
      21.times do
        concert = create(:concert)
        @star.hoi_concert(concert)
      end
      get :show, id: @star
      expect(@star.concerts.page.size).to eq 20 
    end

    it "should get star's topics if exist" do
      topic = create(:star_topic, subject_id: @star.id)
      get :show, id: @star
      expect(@star.topics.first).to eq topic 
    end

    it "should paginate star's topics if exist" do
      21.times do
        topic = create(:star_topic, subject_id: @star.id)
      end
      get :show, id: @star
      expect(@star.topics.page.size).to eq 20 
    end

    it "should get star's followers if exist" do
      user = create(:user)
      user.follow_star(@star)
      get :show, id: @star
      expect(@star.followers.first).to eq user 
    end

    it "should paginate star's followers if exist" do
      21.times do
        user = create(:user)
        user.follow_star(@star)
      end
      get :show, id: @star
      expect(@star.followers.page.size).to eq 20 
    end
  end

  describe 'GET #index' do
    before :each do
      admin = create :admin
      session[:admin_id] = admin.id
      @smith = create(:star, name: 'Smith', position: 1)
      @jones = create(:star, name: 'Jones', position: 2)
    end

    context 'with order(:position)' do
      it "populates an array of stars order by position" do 
        get :index 
        expect(Star.order(:position)).to eq [@smith, @jones]
      end

      it "renders the :index template" do
        get :index 
        expect(response).to render_template :index
      end
    end
  end
end
