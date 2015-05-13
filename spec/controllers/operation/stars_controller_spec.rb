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

  describe 'GET #new' do
    before :each do
      admin = create :admin
      session[:admin_id] = admin.id
    end

    it "assigns a new Star to @star" do
      get :new
      expect(assigns(:star)).to be_a_new(Star) 
    end

    it "renders the :new template" do 
      get :new
      expect(response).to render_template :new 
    end
  end

  describe 'GET #edit' do
    before :each do
      admin = create :admin
      session[:admin_id] = admin.id
    end

    it "assigns the requested star to @star" do 
      star = create(:star)
      get :edit, id: star 
      expect(assigns(:star)).to eq star
    end

    it "renders the :edit template" do
      star = create(:star)
      get :edit, id: star 
      expect(response).to render_template :edit
    end 
  end

  describe 'POST #create' do
    before :each do
      admin = create :admin
      session[:admin_id] = admin.id
      @video = attributes_for(:video)
    end

    context "with invalid attributes" do
      it "does not save the new star in the database" do
        expect{
          post :create, star: attributes_for(:invalid_star)
        }.to_not change(Star, :count)
      end

      it "re-renders the :new template" do 
        post :create, star: attributes_for(:invalid_star)
        expect(response).to render_template :new
      end 
    end

    context "with valid attributes" do
      it "saves the new star in the database" do
        expect{
          post :create, star: attributes_for(:star, video: @video, description: "THE LAST OF US")
        }.to change(Star, :count).by(1)
      end

      it "redirects to stars#show" do
        post :create, star: attributes_for(:star, video: @video)
        expect(response).to redirect_to operation_star_path(assigns[:star])
      end 
    end
  end

  describe "PATCH sort" do 
    before :each do
      @star1 = create(:star) 
      @star2 = create(:star) 
      admin = create :admin
      session[:admin_id] = admin.id
    end

    it "set star's position" do
      patch :sort, star: [@star2.id, @star1.id] 
      expect @star2.reload.position < @star1.reload.position
    end

    it "render nothing" do
      patch :sort, star: [@star2.id, @star1.id] 
      expect(response.status).to eq 200
    end 
  end
end
