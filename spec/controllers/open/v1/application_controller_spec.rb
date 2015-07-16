require 'spec_helper'
class AnonymousController < Open::V1::ApplicationController
end

describe Open::V1::ApplicationController do
  controller(AnonymousController) do
    def prepare_method
      render json: { result_code: 0 }
    end
  end

  specify "a custom action can be requested if routes are drawn manually" do
    routes.draw { get "prepare_method" => "anonymous#prepare_method" }

    get :prepare_method
    expect(response.status).to be(404)
  end

  before :each do
    request.env["HTTP_ACCEPT"] = 'application/json'
    routes.draw { get "prepare_method" => "anonymous#prepare_method" }
  end

  let(:auth) { ApiAuth.create(user: ApiAuth::DANCHE_SERVER) }
  let(:timestamp) { Time.now.to_i }

  context "#prepare_method with correct out channel params" do
    it "should get 30 cities" do
      sign = (Digest::MD5.hexdigest("api_key=#{auth.key}&timestamp=#{timestamp}#{auth.secretcode}")).upcase
      get :prepare_method, api_key: auth.key, timestamp: timestamp, sign: sign
      expect(json[:result_code]).to eq 0
    end
  end

  context "#prepare_method with incorrect out channel params" do
    it "should return code 1003 if params missing" do
      get :prepare_method, api_key: auth.key
      expect(json[:result_code]).to eq 1003
    end

    it "should return code 1001 if channel not exist" do
      get :prepare_method, api_key: "hah", timestamp: 11, sign: "pjpl"
      expect(json[:result_code]).to eq 1001
    end

    it "should return code 1002 if request time has passed 10 minutes" do
      timestamp = (Time.now - 601).to_i
      sign = Digest::MD5.hexdigest("api_key=#{auth.key}&timestamp=#{timestamp}#{auth.secretcode}")
      get :prepare_method, api_key: auth.key, timestamp: timestamp, sign: sign
      expect(json[:result_code]).to eq 1004
    end

    it "should return code 1002 if sign is not the same" do
      get :prepare_method, api_key: auth.key, timestamp: timestamp, sign: "xxxxxxxx"
      expect(json[:result_code]).to eq 1002
    end
  end
end
