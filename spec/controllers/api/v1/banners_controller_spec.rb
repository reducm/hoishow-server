require 'rails_helper'

RSpec.describe Api::V1::BannersController, :type => :controller do
  render_views
  before('each') do
    @concert = create :concert
    5.times do
      create :banner, subject_type: "Concert", subject_id: @concert.id
    end
  end

  context "#index" do
     it "index should be success" do
       get :index, with_key(format: :json)
       expect(response.status).to eq 200
       expect(JSON.parse(response.body).count).to eq 5
       #"subject" 要有东西
       expect(JSON.parse(response.body)[0]["subject"].keys.count > 0).to be true
     end

     it "article banner sould has no subject" do
       Banner.destroy_all
       banner = create :article_banner
       get :index, with_key(format: :json)
       expect(JSON.parse(response.body)[0]["subject"].blank?).to be true
     end
  end
end
