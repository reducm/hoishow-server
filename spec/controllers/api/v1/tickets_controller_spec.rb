require 'rails_helper'

RSpec.describe Api::V1::TicketsController, :type => :controller do
  render_views

  before('each') do
    60.times do |i| 
      create(:ticket, code: i)
    end 
  end

  context "#index" do
    it "should get 20 tickets" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end    

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("area")
      expect(response.body).to include("show")
      expect(response.body).to include("area_id")
      expect(response.body).to include("show_id")
      expect(response.body).to include("price")
      expect(response.body).to include("code")
      expect(response.body).to include("status")
      expect(response.body).to include("created_at")
      expect(response.body).to include("updated_at")
    end
  end

  it "area should has something" do
    get :index, with_key(format: :json)
    20.times do |n|
      expect(JSON.parse( response.body )[n-1]["area"].size > 0 ).to be true
    end
  end

  context "#index paginate test" do
    it "with page params" do
      get :index, with_key(page: 2, format: :json)
      tickets_code = Ticket.pluck(:code)
      expect(JSON.parse(response.body).first["code"]).to eq tickets_code[20] #第二页第一个 
    end
  end

end
