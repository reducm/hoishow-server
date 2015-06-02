require 'rails_helper'

RSpec.describe Api::V1::ConcertsController, :type => :controller do
  render_views

  context "#index without user" do
    before('each') do
      30.times {create :concert}
    end

    it "should get 20 concerts without user" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 10
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
      expect(response.body).to include("is_voted")
      expect(response.body).to include("is_top")
      expect(response.body).to include("voted_city")
      JSON.parse(response.body).each do|object|
        expect(object["is_followed"]).to be false
        expect(object["is_voted"]).to be false
      end
    end
  end

  context "#index paginate test" do
    before('each') do
      100.times {create :concert}
    end

    it "should get 20 concerts without user" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 10
    end
  end

  context "#index with user" do
    before('each') do
      9.times {create :concert}
      @user = create :user
      city = create :city
      Concert.limit(5).each do |concert|
        @user.follow_concert(concert)
      end
      Concert.limit(3).each do |concert|
        @user.vote_concert(concert, city)
      end
    end

    it "5 concerts is_followed should be true " do
      get :index, with_key(api_token: @user.api_token, mobile: @user.mobile, format: :json)
      expect(response.body).to include("is_followed")
      followed_concerts = JSON.parse(response.body).select{|concert| concert["is_followed"] == true}
      expect(followed_concerts.size).to eq 5

      expect(response.body).to include("is_voted")
      voted_concerts = JSON.parse(response.body).select{|concert| concert["is_voted"] == true}
      expect(voted_concerts.size).to eq 3
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
      expect(response.body).to include("topics")
      expect(response.body).to include("is_top")
    end

    it "status should going string" do
      get :show, with_key(id: @concert.id, format: :json)
      expect(JSON.parse(response.body)["status"]).to eq "voting"
    end

    it "stars should has something" do
      @star = create :star
      @star.hoi_concert(@concert)
      get :show, with_key(id: @concert.id, format: :json)
      expect(JSON.parse( response.body )["stars"].size > 0 ).to be true
    end

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

  context "#city_rank" do
    before('each') do
      @concert = create :concert
      @city1 = create :city
      @city2 = create :city
      @user1 = create :user
      @user2 = create :user
      @user3 = create :user
      @city1.hold_concert(@concert)
      @city2.hold_concert(@concert)
      @user1.vote_concert(@concert, @city1)
      @user3.vote_concert(@concert, @city2)
      @user2.vote_concert(@concert, @city2)
    end

    it "should has something" do
      get :city_rank, with_key(id: @concert.id, format: :json)
      expect(response.body).to include("vote_count")
    end

    it "city does not display when has show" do
      show = create :show, concert: @concert, city: @city1
      get :city_rank, with_key(id: @concert.id, format: :json)
      expect(JSON.parse(response.body).size).to eq 1
      expect(JSON.parse(response.body).first["id"]).to_not eq @city1.id
    end
  end
end

