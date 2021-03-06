# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :area do
    sequence(:name) {|n| "Fuck#{n}"}
    seats_count {Random.rand(10..100)}
    left_seats {Random.rand(10..100)}
    association :stadium
    source_id {Random.rand(10..100)}
    factory :yongle_area do
      source Area.sources['yongle']
    end
  end
end
