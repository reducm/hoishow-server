# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_follow_star do
    user :user
    star :star
  end
end
