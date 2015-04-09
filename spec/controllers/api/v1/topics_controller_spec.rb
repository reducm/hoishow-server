require 'rails_helper'

RSpec.describe Api::V1::TopicsController, :type => :controller do
  render_views
  
  #context "#index" do
    #before('each') do
      #30.times {create :star_topic}
      #30.times {create :concert_topic}
    #end

    #it "should get 20 star topics" do
      #get :index, with_key(subject_type: topic.subject_type, subject_id: topic.subject_id,  format: :json)
      #expect(JSON.parse(response.body).is_a? Array).to be true
      #expect(JSON.parse(response.body).size).to eq 20
    #end    

    #it "should get 20 concert topics" do
      #get :index, with_key(subject_type:format: :json)
      #expect(JSON.parse(response.body).is_a? Array).to be true
      #expect(JSON.parse(response.body).size).to eq 20
    #end    

    #it "should has attributes" do
      #get :index, with_key(format: :json)
      #expect(response.body).to include("id")
      #expect(response.body).to include("name")
      #expect(response.body).to include("description")
      #expect(response.body).to include("start_date")
      #expect(response.body).to include("end_date")
      #expect(response.body).to include("status")
      #expect(response.body).to include("shows_count")
      #expect(response.body).to include("is_voted")
      #JSON.parse(response.body).each do|object| 
        #expect(object["is_followed"]).to be false
        #expect(object["is_voted"]).to be false
      #end
    #end
  #end

  #context "#index paginate test" do
    #before('each') do
      #100.times {create :topic}
    #end

    #it "should get 20 topics without user" do
      #get :index, with_key(format: :json)
      #expect(JSON.parse(response.body).is_a? Array).to be true
      #expect(JSON.parse(response.body).size).to eq 20
    #end    

    #it "with page params" do
      #get :index, with_key(page: 2, format: :json)
      #topics_id = topic.pluck(:id)
      #expect(topics_id.index JSON.parse(response.body).first["id"].to_i).to eq 20
    #end
  #end



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
