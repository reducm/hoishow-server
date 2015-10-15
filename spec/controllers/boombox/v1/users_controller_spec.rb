require 'rails_helper'

RSpec.describe Boombox::V1::UsersController, :type => :controller do
  include BoomboxInitHelper

  context "#verification" do
    it "should get success" do
      get :verification, encrypted_params_in_boombox(api_key)
      expect(json["result"]).to eq "success"
    end
  end
end
