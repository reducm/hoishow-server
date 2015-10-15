require 'rails_helper'

RSpec.describe Boombox::V1::CollaboratorsController, :type => :controller do
  render_views
  let(:api_key){ create(:api_auth) }
  let(:json) { JSON.parse(response.body) }
  before(:each) do
    request.accept = "application/json"
  end

  context "#index" do
    before('each') do
      10.times {create :collaborator}
    end

    it "should get 10 collaborators" do
      get :index, encrypted_params_in_boombox(api_key)
      expect(json.is_a? Array).to be true
      expect(json.size).to eq 10
    end
  end

  context "#index paginate test" do
    before('each') do
      20.times {create :collaborator}
    end

    it "should get 10 without page" do
      get :index, encrypted_params_in_boombox(api_key)
      expect(json.size).to eq 10
    end
  end

  context "#show" do
    before('each') do
      @collaborator = create :collaborator
      @user = create :user
      create :user_follow_collaborator, user: @user, collaborator: @collaborator
    end

    it "should has attributes" do
      options = {id: @collaborator.id}
      get :show, encrypted_params_in_boombox(api_key, options)
    end
  end
end
