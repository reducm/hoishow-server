# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    type 1
    title "MyString"
    content "MyText"
    subject_type "MyString"
    subject_id 1
    creator_type "MyString"
    creator_id 1
  end
end
