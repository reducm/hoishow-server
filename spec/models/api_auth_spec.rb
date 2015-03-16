require 'spec_helper'

describe ApiAuth do
  context "validation" do
    it "user should be presence" do
      a = ApiAuth.new
      expect(a.valid?).to be_false
      expect(a).to have(1).error_on(:user)
    end

    it "key should be presence after_create" do
      a = ApiAuth.create(user: "ios")
      expect(a.valid?).to be_true
      expect(a.key.present?).to be_true
    end
  end
end
