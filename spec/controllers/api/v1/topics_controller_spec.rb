require 'rails_helper'

RSpec.describe Api::V1::TopicsController, :type => :controller do
  render_views

  before('each') do
    @user = create :user
  end

  context "#index without subject" do
    before('each') do
      30.times {create :topic}
    end

    it "should get 20 topics" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("content")
      expect(response.body).to include("is_top")
      expect(response.body).to include("like_count")
      expect(response.body).to include("subject_type")
      expect(response.body).to include("subject_id")
      expect(response.body).to include("created_at")
      expect(response.body).to include("creator")
      expect(response.body).to include("comments_count")
      expect(response.body).to include("is_like")
    end

    it "should is_like true if user like topic" do
      @topic = create :topic
      @user = create :user
      @user.like_topic(@topic)
      get :index, with_key(api_token: @user.api_token, mobile: @user.mobile, page: 2, format: :json)
      expect(JSON.parse(response.body).last["is_like"]).to be true
    end
  end


  context "#index of concert's topic" do
    before('each') do
      @concert = create :concert
      30.times do
        create(:concert_topic, subject_type: @concert.name, subject_id: @concert.id)
      end
    end

    it "should get 20 topics" do
      get :index, with_key(subject_type: @concert.name, subject_id: @concert.id, format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end

    it "should has attributes" do
      get :index, with_key(subject_type: @concert.name, subject_id: @concert.id, format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("content")
      expect(response.body).to include("is_top")
      expect(response.body).to include("like_count")
      expect(response.body).to include("subject_type")
      expect(response.body).to include("subject_id")
      expect(response.body).to include("created_at")
      expect(response.body).to include("city") # concert的topic要有city
      expect(response.body).to include("creator")
      expect(response.body).to include("comments_count")
      expect(response.body).to include("is_like")
    end
  end

  context "#index of star's topic" do
    before('each') do
      @star = create :star
      30.times do
        create(:star_topic, subject_type: @star.name, subject_id: @star.id)
      end
    end

    it "should get 20 topics" do
      get :index, with_key(subject_type: @star.name, subject_id: @star.id, format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end

    it "should has attributes" do
      get :index, with_key(subject_type: @star.name, subject_id: @star.id, format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("content")
      expect(response.body).to include("is_top")
      expect(response.body).to include("like_count")
      expect(response.body).to include("subject_type")
      expect(response.body).to include("subject_id")
      expect(response.body).to include("created_at")
      expect(response.body).to include("creator")
      expect(response.body).to include("comments_count")
      expect(response.body).to include("is_like")
    end
  end

  context "#index paginate test" do
    before('each') do
      @concert = create :concert
      60.times do
        create(:concert_topic, subject_type: @concert.name, subject_id: @concert.id)
      end
    end
  end

  context "#show" do
    it "should has attributes" do
      @user = create :user
      @topic = create :topic
      @user.like_topic(@topic)
      get :show, with_key(user: @user, id: @topic.id, format: :json)
      expect(response.body).to include("creator")
      expect(response.body).to include("content")
      expect(response.body).to include("comments")
      expect(response.body).to include("comments_count")
      expect(response.body).to include("is_like")
    end

    it "should is_like true if user like topic" do
      @topic = create :topic
      @user = create :user
      @user.like_topic(@topic)
      get :show, with_key(id: @topic.id, api_token: @user.api_token, mobile: @user.mobile, format: :json)
      expect(JSON.parse(response.body)["is_like"]).to be true
    end
  end

end
