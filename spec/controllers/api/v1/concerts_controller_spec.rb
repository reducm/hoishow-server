require 'rails_helper'

RSpec.describe Api::V1::ConcertsController, :type => :controller do
  render_views

  context "#index without user" do
    before('each') do
      30.times {create :concert}
    end

    it "should get 18 shows without user" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end    

    it "should has attributes" do
      get :index, with_key(format: :json)
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

    context "#index with user" do
      before('each') do
        9.times {create :concert}
        @user = create :user
        Concert.limit(5).each do |concert|
          @user.follow_concert(concert) 
        end
      end

      it "5 concerts is_followed should be true " do
        get :index, with_key(api_token: @user.api_token, mobile: @user.mobile, format: :json)
        expect(response.body).to include("is_followed")
        followed_concerts = JSON.parse(response.body).select{|concert| concert["is_followed"] == true}
        expect(followed_concerts.size).to eq 5
      end

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
      expect(response.body).to include("cities")
      expect(response.body).to include("stars")
      expect(response.body).to include("shows")
      expect(response.body).to include("comments")
    end

    #it "stars sholud has something real" do
      #binding.pry
      #@star = create(:star)
      #@star.hoi_concert(@concert)
      #get :show, with_key(id: @user.id, format: :json)
      #expect(JSON.parse( response.body )["stars"].size > 0 ).to be true
    #end

    #it "comments sholud has something real" do
      #@user = create :user
      #3.times do|n|
        #@user.comments.create_comment(@star, "fuck you#{n}")
      #end
      #get :show, with_key(id: @star.id, format: :json)
      #expect(JSON.parse( response.body )["comments"].size > 0 ).to be true
    #end

    #it "shows sholud has something real" do
      #3.times do
        #concert = create(:concert)
        #@star.hoi_concert(concert)
        #3.times{|n| create(:show, concert: concert)}
      #end
      #get :show, with_key(id: @star.id, format: :json)
      #expect(JSON.parse( response.body )["shows"].size > 0 ).to be true
      #ap JSON.parse( response.body )
    #end
  #end

  #context "#show with user" do
    #before('each') do
      #3.times {create :concert}     
      #@user = create :user
      #Star.limit(3).each do |concert|
        #@user.follow_concert(concert)
      #end
    #end

    #it "3 concerts is_followed should be true " do
      #get :show, with_key(id: concert.first.id, api_token: @user.api_token, mobile: @user.mobile, format: :json)
      #expect(response.body).to include("is_followed")
      #expect(JSON.parse(response.body)["is_followed"]).to be true
    #end

  end

end
