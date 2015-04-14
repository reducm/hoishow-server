require 'rails_helper'

RSpec.describe Api::V1::CommentsController, :type => :controller do
  render_views

  context "#index" do
    before('each') do
      30.times {create :comment}
    end

    it "should get 20 comments" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end    

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("topic_id")
      expect(response.body).to include("content")
      expect(response.body).to include("parent_id")
      expect(response.body).to include("user")
    end
  end

  context "#index paginate test" do
    before('each') do
      100.times {create :comment}
    end
    
    it "with page params" do
      get :index, with_key(page: 2, format: :json)
      comments_id = Comment.pluck(:id)
      expect(comments_id.index JSON.parse(response.body).first["id"].to_i).to eq 20
    end
  end

end
