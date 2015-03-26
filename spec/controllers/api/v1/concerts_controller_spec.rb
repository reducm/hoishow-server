require 'rails_helper'

RSpec.describe Api::V1::ConcertsController, :type => :controller do
  render_views

  context "#get all concerts without user" do
    before('each') do
      30.times {create :concert}
    end

    it "should get 20 concerts without user" do
      #      get :index, with_key(format: :json)
      get :get_all_object, with_key(object_type: "concert", format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end    

    it "should has attributes" do
      #get :index, with_key(format: :json)
      get :get_all_object, with_key(object_type: "concert", format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
      expect(response.body).to include("description")
      expect(response.body).to include("start_date")
      expect(response.body).to include("end_date")
      expect(response.body).to include("status")
      expect(response.body).to include("shows_count")
      JSON.parse(response.body).each do|object| 
        expect(object["is_followed"]).to be false
      end
    end

  end

  context "#get all concerts with user" do
    before('each') do
      9.times {create :concert}
      @user = create :user
      Concert.limit(5).each do |concert|
        @user.follow_concert(concert) 
      end
    end

    it "5 concerts is_followed should be true " do
      #  get :index, with_key(api_token: @user.api_token, mobile: @user.mobile, format: :json)
      get :get_all_object, with_key(api_token: @user.api_token, mobile: @user.mobile, object_type: "concert", format: :json)
      expect(response.body).to include("is_followed")
      followed_concerts = JSON.parse(response.body).select{|concert| concert["is_followed"] == true}
      expect(followed_concerts.size).to eq 5
    end

  end

  context "#get all shows without user" do
    before('each') do
      20.times { create :show  }
    end

    it "should get 10 shows without user" do
      get :get_all_object, with_key(object_type: "show", format: :json)
      expect(response.status).to eq 200
      expect(JSON.parse(response.body).size).to eq 10
    end

    it "should has attributes" do
      #get :index, with_key(format: :json)
      get :get_all_object, with_key(object_type: "show", format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
      expect(response.body).to include("min_price")
      expect(response.body).to include("max_price")
      expect(response.body).to include("concert_id")
      expect(response.body).to include("show_time")
      expect(response.body).to include("concert")
      expect(response.body).to include("city")
    end


  end

end
