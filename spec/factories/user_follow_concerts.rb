# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_follow_concert do
    user :user
    concert :concert
  end
end
