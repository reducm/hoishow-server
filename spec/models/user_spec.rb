require 'spec_helper'

describe User do
  before('each') do
    @user = create(:user) 
  end

  context "validates" do
    it "name should be presences" do
      user = User.new
      expect(user.valid?).to be_false
      expect(user).to have(2).error_on(:mobile)
    end

    it "name should be formated" do
      user = User.new(mobile: "123")
      expect(user.valid?).to be_false
      expect(user).to have(1).error_on(:mobile)
    end

    it "name should be uniqueness" do
      user = User.new(mobile: @user.mobile)
      expect(user.valid?).to be_false
      expect(user).to have(1).error_on(:mobile)
    end

  end
end
