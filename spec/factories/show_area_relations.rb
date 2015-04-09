# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :show_area_relation do
    association :show
    association :area
    price {Random.rand(10..100)}
    seats_count {Random.rand(10..100)}
  end
end
