require 'rails_helper'

RSpec.describe Api::V1::ShowsController, :type => :controller do
  render_views

  context "#index" do
    before('each') do
      30.times {create :show}
    end

    it "should get 20 (base on model paginates_per) shows" do
      get :index, with_key(format: :json)
      expect(JSON.parse(response.body).is_a? Array).to be true
      expect(JSON.parse(response.body).size).to eq 20
    end

    it "should has attributes" do
      get :index, with_key(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("name")
      expect(response.body).to include("min_price")
      expect(response.body).to include("max_price")
      expect(response.body).to include("concert_id")
      expect(response.body).to include("city_id")
      expect(response.body).to include("stadium_id")
      expect(response.body).to include("show_time")
      expect(response.body).to include("poster")
      expect(response.body).to include("description")
      expect(response.body).to include("is_followed")
    end
  end

  context "#show" do
    it "concert should has something" do
      @concert = create :concert
      @show = create(:show, concert: @concert)
      get :show, with_key(id: @show.id, format: :json)
      expect(JSON.parse(response.body)["concert"].size > 0).to be true
    end

    it "stadium should has something" do
      @stadium = create :stadium
      @show = create(:show, stadium: @stadium)
      get :show, with_key(id: @show.id, format: :json)
      expect(JSON.parse(response.body)["stadium"].size > 0).to be true
    end

    it "city should has something" do
      @city = create :city
      @stadium = create(:stadium, city: @city)
      @show = create(:show, city: @stadium.city)
      get :show, with_key(id: @show.id, format: :json)
      expect(JSON.parse(response.body)["city"].size > 0).to be true
    end
  end

  context "#preorder" do
    before('each') do
      @stadium = create :stadium
      10.times{create :area, stadium: @stadium}
      @show = create :show, stadium: @stadium
      Area.all.each_with_index do |area, i|
        relation = create :show_area_relation, area: area, show: @show
      end
    end

    it "response should has something" do
      get :preorder, with_key(id: @show.id, format: :json)
      expect(response.body).to include("stadium")
      expect(response.body).to include("areas")
      expect(response.body).to include("is_sold_out")
      expect(response.body).to include("show")
    end
  end
end
