# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    subject_type "Star"
    subject_id "1"
    content "fuck you"
    association :user
  end
end
