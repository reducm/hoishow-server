# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    amount {Random.rand(1..10)}
    concert_name {Faker::Name.name}
    stadium_name {Faker::Name.name}
    valid_time {Faker::Name.name}
    out_id {Faker::Name.name}
    city_name {Faker::Name.name}
    star_name {Faker::Name.name}
    show_name {Faker::Name.name}
    association :user
    concert_id 1
    city_id 1
    stadium_id 1
    star_id 1
    show_id 1
    seats_info "12.0:1|13.0|2"
  end
end
