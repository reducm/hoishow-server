# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :topic do
    creator_type "User"
    creator_id 1
    subject_type "Star"
    subject_id 1
    content "MyText"
    is_top false
    city_id nil
    factory :concert_topic do
      creator_type "User"
      creator_id 1
      subject_type Concert.name
      subject_id 1
      association :city
    end
    factory :star_topic do
      creator_type "User"
      creator_id 1
      subject_type Star.name
      subject_id 1
    end
  end
end
