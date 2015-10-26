# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :boom_comment do
    content "hahahahah"
    creator_id 1
    creator_type "User"
  end
end
