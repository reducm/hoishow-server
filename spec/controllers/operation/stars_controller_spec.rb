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

    it "should get star's followers if exist" do
      user = create(:user)
      user.follow_star(@star)
      get :show, id: @star
      expect(@star.followers.first).to eq user
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
      expect(@star.concerts.page.size).to eq 10
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
      expect(@star.topics.page.size).to eq 10
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
      expect(@star.followers.page.size).to eq 10
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
    end

    context "with invalid star attributes" do
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

    context "with valid star attributes without video" do
      it "save the new star in the database" do
        expect{
          post :create, star: attributes_for(:star)
        }.to change(Star, :count).by(1)
      end

      it "redirect_to star's show page" do
        post :create, star: attributes_for(:star)
        expect(response).to redirect_to operation_star_path(assigns[:star])
      end
    end
  end

  describe 'PATCH #update' do
    before :each do
      admin = create :admin
      session[:admin_id] = admin.id
      @star = create(:star, name: "tom总")
    end

    context "valid attributes" do
      it "locates the requested @star" do
        patch :update, id: @star, star: attributes_for(:star)
        expect(assigns(:star)).to eq(@star)
      end

      it "changes @star's attributes" do
        patch :update, id: @star, star: attributes_for(:star, name: "大佬")
        @star.reload
        expect(@star.name).to eq("大佬")
      end

      it "redirects to the updated star" do
        patch :update, id: @star, star: attributes_for(:star)
        expect(response).to redirect_to operation_star_path(@star)
      end
    end

    context "with invalid attributes" do
      it "dose not change star's attributes" do
        patch :update, id: @star, star: attributes_for(:star, name: nil)
        @star.reload
        expect(@star.name).to eq("tom总")
      end

      it "re-render edit page" do
        patch :update, id: @star, star: attributes_for(:star, name: nil)
        @star.reload
        expect(response).to render_template :edit
      end
    end
  end
end
