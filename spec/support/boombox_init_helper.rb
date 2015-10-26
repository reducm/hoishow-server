module BoomboxInitHelper
  def self.included(base)
    base.render_views
    base.let(:api_key){ create(:api_auth) }
    base.let(:json) { JSON.parse(response.body) }
    base.before(:each) do
      request.accept = "application/json"
    end
  end
end
