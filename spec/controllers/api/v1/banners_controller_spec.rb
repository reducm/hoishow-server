require 'rails_helper'

RSpec.describe Api::V1::BannersController, :type => :controller do
  render_views
  before('each') do
    @concert = create :concert
    5.times do
      create :banner, subject_type: "Concert", subject_id: @concert.id
    end
    @article_banner = create :article_banner
  end

  context "#index" do
     it "index should be success" do
       get :index, with_key(format: :json)
       expect(response.status).to eq 200
       expect(JSON.parse(response.body).count).to eq 5
     end
  end
end
