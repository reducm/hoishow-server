require 'rails_helper'

RSpec.describe Api::V1::StarsController, :type => :controller do
  render_views

  context "#index without user" do
    before('each') do
      10.times {create :star}
    end

    it "should order by position" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body)[0]["position"] < JSON.parse(response.body)[1]["position"]).to be true
    end

    it "should get 20 shows without user" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 10
    end

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
      expect(response.body).to include("position")
      expect(response.body).to include("status_cn")
      expect(response.body).to include("avatar")
      expect(response.body).to include("is_followed")
      expect(response.body).to include("followers_count")
      JSON.parse(response.body).each do|object|
        expect(object["is_followed"]).to be false
      end
    end
  end

  context "#index paginate test" do
    before('each') do
      10.times {create :star}
    end

    it "should get 20 stars without user" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 10
    end
  end

  context "#index with user" do
    before('each') do
      5.times {create :star}
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
      expect(response.body).to include("position")
      expect(response.body).to include("status_cn")
      expect(response.body).to include("avatar")
      expect(response.body).to include("poster")
      expect(response.body).to include("is_followed")
      expect(response.body).to include("concerts")
      expect(response.body).to include("video")
      expect(response.body).to include("shows")
    end

    it "video sholud has something real if star has main video" do
      create(:video, star_id: @star.id, is_main: true)
      get :show, with_key(id: @star.id, format: :json)
      expect(JSON.parse( response.body )["video"].size > 0 ).to be true
    end

    it "video sholud be empty string if star does not have main video" do
      create(:video, star_id: @star.id, is_main: false)
      get :show, with_key(id: @star.id, format: :json)
      expect(JSON.parse( response.body )["video"]).to eq nil
    end

    it "video sholud be empty string if video is invalid" do
      Video.create(star_id: @star.id, is_main: true, source: "aa.mp4")
      get :show, with_key(id: @star.id, format: :json)
      expect(JSON.parse( response.body )["video"]).to eq nil
    end

    it "concerts sholud has something real" do
      3.times do
        concert = create(:concert)
        @star.hoi_concert(concert)
      end
      get :show, with_key(id: @star.id, format: :json)
      expect(JSON.parse( response.body )["concerts"].size > 0 ).to be true
    end

    it "shows sholud has something real" do
      3.times do
        concert = create(:concert)
        @star.hoi_concert(concert)
        3.times{|n| create(:show, concert: concert)}
      end
      get :show, with_key(id: @star.id, format: :json)
      expect(JSON.parse( response.body )["shows"].size > 0 ).to be true
    end
  end

  context "#show with user" do
    before('each') do
      3.times {create :star}
      @user = create :user
      Star.limit(3).each do |star|
        #关注
        @user.follow_star(star)
        #concert被关注
        concert = create :concert
        @user.follow_concert(concert)
        star.hoi_concert(concert)
      end
    end

    it "should has attributes" do
      get :show, with_key(id: Star.first.id, api_token: @user.api_token, mobile: @user.mobile, format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
      expect(response.body).to include("position")
      expect(response.body).to include("status_cn")
      expect(response.body).to include("avatar")
      expect(response.body).to include("poster")
      expect(response.body).to include("is_followed")
      expect(response.body).to include("concerts")
      expect(response.body).to include("video")
      expect(response.body).to include("shows")
    end

    it "3 stars is_followed should be true " do
      get :show, with_key(id: Star.first.id, api_token: @user.api_token, mobile: @user.mobile, format: :json)
      expect(response.body).to include("is_followed")
      expect(JSON.parse(response.body)["is_followed"]).to be true
    end

    it "if user has followed concert, concert should be is_followed true" do
      get :show, with_key(id: Star.first.id, api_token: @user.api_token, mobile: @user.mobile, format: :json)
      expect(JSON.parse(response.body)["concerts"].first["is_followed"]).to be true
    end

    it "should have topic staff" do
      Star.all.each do |star|
        #创建topic
        topic = star.topics.create(content: Base64.encode64("fuck tom"), subject_type: Star.name, creator_type: User.name, creator_id: (create :user).id)
        @user.like_topic(topic)
      end
      get :show, with_key(id: Star.first.id, api_token: @user.api_token, mobile: @user.mobile, format: :json)
      expect(JSON.parse(response.body)["topics"].count > 0 ).to be true
      expect(JSON.parse(response.body)["topics"].first["is_like"] ).to be true
    end
  end

  context "#search" do
    before('each') do
      3.times {|n|create(:star, name: "tom#{n}")}
      4.times {|n|create(:star, name: "xo#{n}")}
      2.times {|n|create(:star, name: "芙蓉#{n}")}
    end

    it "search should has results" do
      get :search, with_key(q: "tom", format: :json)
      expect(JSON.parse(response.body).size).to eq 3
    end

    it "search should has results when input chinese" do
      get :search, with_key(q: "蓉", format: :json)
      expect(JSON.parse(response.body).size).to eq 2
    end

    it "search should has results when input single word" do
      get :search, with_key(q: "o", format: :json)
      expect(JSON.parse(response.body).size).to eq 7
    end
  end
end
