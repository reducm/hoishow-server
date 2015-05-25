require 'rails_helper'

RSpec.describe Operation::TopicsController, :type => :controller do
  render_views
  before('each') do
    admin = create :admin
    login(admin)
  end

  context "#add_comment" do
    before('each') do
      @star = create :star
      @concert = create :concert
      @show = create :show
      user = create :user
      @city = create :city
      @stadium = create :stadium
      @topic = create :topic
      @comment = create :comment
      user.follow_star(@star)
      user.vote_concert(@concert, @city)
      user.follow_concert(@concert)
      user.follow_show(@show)
    end

    it "saves the new comment in the database" do
      expect {
        post :add_comment, id: @topic, content: "skdafkjfd", creator: @star.id 
      }.to change(Comment, :count).by(1)
    end

    it "saves the new message in the database" do
      expect {
        post :add_comment, id: @topic, content: "skdafkjfd", creator: @star.id 
      }.to change(Message, :count).by(1)
    end

    it "saves the new message in the database" do
      expect {
        post :add_comment, id: @topic, content: "skdafkjfd", creator: @star.id, parent_id: @comment.id
      }.to change(Message, :count).by(2)
    end

  end

end
