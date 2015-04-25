# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    content "fuck you"
    creator_type "Star"
    creator_id 1
    association :topic
  end
end
