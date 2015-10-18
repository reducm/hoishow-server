# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :boom_topic do
    created_by "tom"
    subject_type "Activity"
    subject_id 1
    content "anything content"
  end
end
