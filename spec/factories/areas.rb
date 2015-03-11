# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :area do
    sequence(:name) {|n| "Fuck#{n}"}
    seats_count {Random.rand(10..100)}
    stadium :stadium
  end
end
