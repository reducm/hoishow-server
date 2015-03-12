# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    amount {Random.rand(1..10)}
    concert_name {Faker::Namei.name}
    stadium_name {Faker::Namei.name}
    area_name {Faker::Namei.name}
    valid_time {Faker::Namei.name}
    out_id {Faker::Namei.name}
    city_name {Faker::Namei.name}
    star_name {Faker::Namei.name}
    association :user
    concert_id 1
    city_id 1
    stadium_id 1
    star_id 1
    area_id 1
    show_id 1
  end
end
