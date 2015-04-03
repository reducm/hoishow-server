# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    content "fuck you"
    association :user
    association :topic
  end
end
