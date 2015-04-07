require 'rails_helper'

RSpec.describe Api::V1::TopicsController, :type => :controller do
  render_views

  context "#show" do
    it "should has attributes" do
      @topic = create :topic
      get :show, with_key(id: @topic.id, format: :json)
      expect(response.body).to include("creator")
      expect(response.body).to include("content")
      expect(response.body).to include("comments")
      expect(response.body).to include("comments_count")
    end
  end

end
