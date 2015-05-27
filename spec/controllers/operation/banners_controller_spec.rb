require 'rails_helper'

RSpec.describe Operation::BannersController, :type => :controller do
  render_views
  before('each') do
    admin = create :admin
    login(admin)
  end
  context "#index " do
    before('each') do
      5.times do
        create :banner
      end
    end

    it "should get 5 messages" do
      get :index
      expect(assigns(:banners).size).to eq 5
      expect(response).to render_template :index
    end
  end

  context "#new" do
    before('each') do
      @banner = create :banner
    end

    it "get new banner" do
      get :new
      expect(assigns(:banner)).to be_a_new(Banner)
      expect(response).to render_template :new 
    end
  end

  context "#edit" do
    before('each') do
      @banner = create :banner
    end

    it "get  banner" do
      get :edit, id: @banner
      expect(assigns(:banner)).to eq @banner
      expect(response).to render_template :edit
    end
  end

  context "#create" do
    it "create new banner" do
      expect {
        post :create, banner: attributes_for(:banner)
      }.to change(Banner, :count).by(1)
    end
  end

  context "#update" do
    before('each') do
      @banner = create :banner
    end
    it "update banner" do
      patch :update, id: @banner, banner: attributes_for(:banner)
      expect(assigns(:banner)).to eq(@banner)
      expect(response).to redirect_to operation_banners_url
    end
    it "change banner attributes" do
      patch :update, id: @banner, banner: attributes_for(:banner, description:"fuck")
      expect(assigns(:banner).description).to eq("fuck")
    end
  end

  context "#destroy" do
    before :each do
      @banner = create :banner
    end

    it "delete a banner" do
      expect {
        delete :destroy, id: @banner
      }.to change(Banner, :count).by(-1)
      expect(response).to redirect_to operation_banners_url
    end
  end
end
