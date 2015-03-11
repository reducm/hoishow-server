require 'spec_helper'

describe UserFollowConcert do
  before :each do
    @user = create :user
    @concert = create :concert
    @concert2 = create :concert
  end

  context "user and concert has_many ships" do
    it "create has_and_belongs_to_many should success" do
      @user.user_follow_concerts.create(concert: @concert)
      @user.user_follow_concerts.create(concert: @concert2)
      expect(@concert.followers.first).to eq @user
      expect(@concert2.followers.first).to eq @user
    end
  end
end
