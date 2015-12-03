require 'rails_helper'

RSpec.describe Collaborator, :type => :model do
  describe "nickname_updated_at on create" do
    it "should save on create" do
      c = create(:collaborator)
      expect(c.nickname_updated_at).to_not be_nil
    end
  end

  describe "nickname_updated_at on update" do
    before(:each) do
      @c = create(:collaborator)
      # hack for after_create callback
      @c.update(nickname_updated_at: "2014-12-12".to_datetime)
      @nickname_updated_at = @c.nickname_updated_at
    end

    it "should update if nickname has changed" do
      @c.update(nickname: 'the king')
      expect(@c.nickname_updated_at).to_not eq @nickname_updated_at
      expect(@c.nickname).to eq 'the king'
    end

    it "should not update if nickname has not changed" do
      nickname = @c.nickname

      @c.update(name: 'DJ')
      expect(@c.nickname_updated_at).to eq @nickname_updated_at
      expect(@c.nickname).to eq nickname
    end
  end

  describe "validate nickname_changeable" do
    before(:each) do
      @c = create(:collaborator)
      # hack for after_create callback
      @c.update(nickname_updated_at: "2014-12-12".to_datetime)
    end

    it "should validate fail when less than 30 days since last change" do
      @c.update(nickname: 'the king')
      @c.update(nickname: 'the king kong')
      expect(@c).to have(1).errors_on(:nickname_updated_at)
    end

    it "should validate pass when more than 30 days since last change" do
      @c.update(nickname: 'the king')
      expect(@c).to have(0).errors_on(:nickname_updated_at)
      expect(@c.nickname).to eq 'the king'
    end
  end
end
