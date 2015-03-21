require 'rails_helper'

RSpec.describe Api::V1::StarsController, :type => :controller do
  render_views

  context "#index without user" do
    before('each') do
      100.times {create :star}
    end

    it "should get 18 shows without user" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 18
    end    

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
      expect(response.body).to include("avatar")
      expect(response.body).to include("is_followed")
      JSON.parse(response.body).each do|object| 
        expect(object["is_followed"]).to be false
      end
    end
  end

  context "#index with user" do
    before('each') do
      9.times {create :star}     
      @user = create :user
      Star.limit(3).each do |star|
        @user.follow_star(star)
      end
    end

    it "3 stars is_followed should be true " do
      get :index, with_key(api_token: @user.api_token, mobile: @user.mobile, format: :json)
      expect(response.body).to include("is_followed")
      followed_stars = JSON.parse(response.body).select{|star| star["is_followed"] == true}
      expect(followed_stars.size).to eq 3
    end

  end
  
  context "#show without user" do
    before('each') do
     @star = create :star     
    end

    it "should has attributes" do
      get :show, with_key(id: @star.id, format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
      expect(response.body).to include("avatar")
      expect(response.body).to include("is_followed")
      expect(response.body).to include("concerts")
      expect(response.body).to include("videos")
      expect(response.body).to include("shows")
      expect(response.body).to include("comments")
    end

    it "concerts sholud has something real" do
      3.times do
        concert = create(:concert)
        @star.hoi_concert(concert)
      end
      get :show, with_key(id: @star.id, format: :json)
      expect(JSON.parse( response.body )["concerts"].size > 0 ).to be true
      ap JSON.parse( response.body )
    end

    it "comments sholud has something real" do
      @user = create :user
      3.times do|n|
        @user.comments.create_comment(@star, "fuck you#{n}")
      end
      get :show, with_key(id: @star.id, format: :json)
      expect(JSON.parse( response.body )["comments"].size > 0 ).to be true
    end
 
  end
end
