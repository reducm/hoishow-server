require 'spec_helper'

describe User do
  before('each') do
    @user = create(:user)
  end

  context "test sex enum" do
    it "test save" do
      @user.male!
      expect(@user.sex).to eq "male"
      expect(@user.male?).to be true
      expect(User.male.size).to eq 1
    end
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
    # it "mobile should be presences" do
    #   user = User.new
    #   expect(user.valid?).to be_falsey
    #   expect(user).to have(2).error_on(:mobile)
    # end

    it "mobile should be formated" do
      user = User.new(mobile: "123")
      expect(user.valid?).to be_falsey
      expect(user).to have(1).error_on(:mobile)
    end

    it "mobile should be uniqueness" do
      user = User.new(mobile: @user.mobile)
      expect(user.valid?).to be_falsey
      expect(user).to have(1).error_on(:mobile)
    end
  end

  context "#vote_concert" do
    before('each') do
      @concert = create :concert
      @city = create :city
    end

    it "concert/city should be presence" do
      @user.vote_concert(@concert, @city)
      expect(@user.user_vote_concerts.size > 0).to be true
      expect(@user.user_vote_concerts.last.city.present?).to be true
      expect(@user.user_vote_concerts.last.concert.present?).to be true
    end

    it "should follow concert after vote" do
      @user.vote_concert(@concert, @city)
      expect(@user.user_follow_concerts.size > 0).to be true
      expect(@user.user_follow_concerts.last.concert).to eq @concert
    end
  end

  context "#like_topic" do
    it "like_topic should be ok" do
      user = create(:user)
      topic = create(:topic)
      user.like_topic(topic)
      expect(topic.like_count).to eq 1
      expect(user.like_topics.count).to eq 1
    end
  end

  context "#create_comment" do
    before :each do
      @user = create(:user)
    end
    it "user reply comment should create 1 comment success " do
      comment = create :comment
      @user.create_comment(create(:topic), comment.id, "fuck jassssssssss")
      expect(@user.comments.count).to eq 1
    end

    it "user reply comment should create 0 message success " do
      comment = create :comment
      @user.create_comment(create(:topic), comment.id, "fuck jassssssssss")
      expect(@user.messages.count).to eq 0
    end

    it "user reply topic should create 0 message success " do
      comment = create :comment
      @user.create_comment(create(:topic), nil, "fuck jassssssssss")
      expect(@user.messages.count).to eq 0
    end

    it 'user reply self should not create message' do
      topic = create :topic, creator_id: @user.id, creator_type: 'User'
      @user.create_comment(topic, nil, 'test')
      expect(@user.messages.count).to eq 0
    end
  end

  context "avatar" do
    it "user's avatar should save ok!" do
      file = fixture_file_upload("/about.png", "image/png")
      @user.avatar = file
      @user.save!
      expect(@user.valid?).to be true
      expect(@user.avatar.url.present?).to be true
    end
  end

  context "find_or_create_bike_user method" do
    let(:mobile) { '15900001111' }
    let(:bike_user_id) { 300 }

    it 'will create new user when can not find user by bike_user_id and mobile' do
      expect{User.find_or_create_bike_user(mobile, bike_user_id)}.to change(User, :count).by(1)
      u = User.last
      expect(u.mobile).to eq mobile
      expect(u.bike_user_id).to eq 300
      expect(u.channel).to eq 'bike_ticket'
    end

    it 'will association hoishow user when can not find user by bike_user_id' do
      hoishow_user = User.create(mobile: mobile, channel: 'ios')
      expect(hoishow_user.bike_user_id).to be_nil
      expect{User.find_or_create_bike_user(mobile, bike_user_id)}.to change(User, :count).by(0)
      hoishow_user.reload
      expect(hoishow_user.mobile).to eq mobile
      expect(hoishow_user.bike_user_id).to eq 300
      expect(hoishow_user.channel).to eq 'ios'
    end

    it 'will return current user when can find user by bike_user_id' do
      bike_ticket_user = User.create(mobile: mobile, channel: 'bike_ticket', bike_user_id: bike_user_id)
      u = User.find_or_create_bike_user(mobile, bike_ticket_user.id)
      expect(u).to eq bike_ticket_user
      expect{User.find_or_create_bike_user(mobile, bike_user_id)}.to change(User, :count).by(0)
    end

    it 'will update the mobile when user channel was bike_ticket and mobile changed' do
      bike_ticket_user = User.create(mobile: mobile, channel: 'bike_ticket', bike_user_id: bike_user_id)
      u = User.find_or_create_bike_user('13800138000', bike_ticket_user.id)
      expect(u.mobile).to eq '13800138000'
      expect(u.bike_user_id).to eq bike_ticket_user.id
      expect{User.find_or_create_bike_user(mobile, bike_user_id)}.to change(User, :count).by(0)
    end
  end
end
