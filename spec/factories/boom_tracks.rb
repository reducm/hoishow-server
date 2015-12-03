# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :boom_track do
    creator_type "Collaborator"
    creator_id 1
    name "hahah play"
    duration 8888
    artists "tom"
  end
end
