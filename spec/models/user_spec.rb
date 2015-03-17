require 'spec_helper'

describe User do
  before('each') do
    @user = create(:user) 
  end

  context "#find_mobile" do
    it "should create user when a new mobile comin" do
      user = User.find_mobile("13632269944")
      expect(user.new_record?).to be_falsey
    end

    it "wrong mobile should railse exception" do
      expect{User.find_mobile("123")}.to raise_error
    end
  end

  context "#sign_in_api" do
    it "sign_in_api should success" do
      user = create :user
      user.sign_in_api
      expect(user.api_token.present?).to be_truthy
      expect(user.api_expires_in.present?).to be_truthy
    end
  end

  context "validates" do
    it "name should be presences" do
      user = User.new
      expect(user.valid?).to be_falsey
      expect(user).to have(2).error_on(:mobile)
    end

    it "name should be formated" do
      user = User.new(mobile: "123")
      expect(user.valid?).to be_falsey
      expect(user).to have(1).error_on(:mobile)
    end

    it "name should be uniqueness" do
      user = User.new(mobile: @user.mobile)
      expect(user.valid?).to be_falsey
      expect(user).to have(1).error_on(:mobile)
    end

  end
end
