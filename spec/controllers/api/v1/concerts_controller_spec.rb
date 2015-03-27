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
      expect(response.body).to include("is_voted")
      JSON.parse(response.body).each do|object| 
        expect(object["is_followed"]).to be false
        expect(object["is_voted"]).to be false
      end
    end

    context "#get all concerts with user" do
      before('each') do
        9.times {create :concert}
        @user = create :user
        Concert.limit(5).each do |concert|
          @user.follow_concert(concert) 
        end
        Concert.limit(3).each do |concert|
          @user.vote_concert(concert)
        end
      end

      it "5 concerts is_followed should be true " do
        #  get :index, with_key(api_token: @user.api_token, mobile: @user.mobile, format: :json)
        get :get_all_object, with_key(api_token: @user.api_token, mobile: @user.mobile, object_type: "concert", format: :json)
        expect(response.body).to include("is_followed")
        followed_concerts = JSON.parse(response.body).select{|concert| concert["is_followed"] == true}
        expect(followed_concerts.size).to eq 5

        expect(response.body).to include("is_voted")
        voted_concerts = JSON.parse(response.body).select{|concert| concert["is_voted"] == true}
        expect(voted_concerts.size).to eq 3
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

    context "#show without user" do
      before('each') do
        @concert = create :concert     
      end

      it "should has attributes" do
        get :show, with_key(id: @concert.id, format: :json)
        expect(response.body).to include("id")
        expect(response.body).to include("name")
        expect(response.body).to include("is_followed")
        expect(response.body).to include("is_voted")
        expect(response.body).to include("cities")
        expect(response.body).to include("stars")
        expect(response.body).to include("shows")
        expect(response.body).to include("comments")
      end

      #TODO stars, shows 

      it "comments sholud has something real" do
        @user = create :user
        3.times do|n|
          @user.comments.create_comment(@concert, "fuck you#{n}")
        end
        get :show, with_key(id: @concert.id, format: :json)
        expect(JSON.parse( response.body )["comments"].size > 0 ).to be true
      end

      context "#show with user" do
        before('each') do
          3.times {create :concert}     
          @user = create :user
          Concert.limit(3).each do |concert|
            @user.follow_concert(concert)
          end
        end

        it "3 concerts is_followed should be true " do
          get :show, with_key(id: Concert.first.id, api_token: @user.api_token, mobile: @user.mobile, format: :json)
          expect(response.body).to include("is_followed")
          expect(JSON.parse(response.body)["is_followed"]).to be true
        end

      end

    end

  end
end
