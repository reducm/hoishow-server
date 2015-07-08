require 'spec_helper'

describe ApiAuth do
  context "validation" do
    it "user should be presence" do
      a = ApiAuth.new
      expect(a.valid?).to be_falsey
      expect(a).to have(1).error_on(:user)
    end

    it "key should be presence after_create" do
      a = ApiAuth.create(user: "ios")
      expect(a.valid?).to be_truthy
      expect(a.key.present?).to be_truthy
    end

    it "secretcode should be presence after_create if channel require_secretcode?" do
      a = ApiAuth.create(user: "dancheServer")
      expect(a.valid?).to be_truthy
      expect(a.secretcode.present?).to be_truthy
    end
  end
end
