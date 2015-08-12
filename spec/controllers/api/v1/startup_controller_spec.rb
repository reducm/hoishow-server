require 'rails_helper'

RSpec.describe Api::V1::StartupController, :type => :controller do
  render_views

  context "#index" do
    it "should return sth" do
      startup = create :startup
      startup.update(is_display: 1)
      get :index, with_key(format: :json)
      expect(response.body).to include("id")
      expect(response.body).to include("pic")
      expect(response.body).to include("valid_time")
    end
  end
end
