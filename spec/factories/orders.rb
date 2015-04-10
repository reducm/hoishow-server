# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    amount {Random.rand(1..10)}
    concert_name {Faker::Name.name}
    stadium_name {Faker::Name.name}
    valid_time {Faker::Name.name}
    out_id {Faker::Name.name}
    city_name {Faker::Name.name}
    show_name {Faker::Name.name}
    association :user
    concert_id 1
    city_id 1
    stadium_id 1
    show_id 1
    factory :paid_order do
      status Order.statuses[:paid]
    end
    factory :success_order do
      status Order.statuses[:success]
    end
    factory :refund_order do
      status Order.statuses[:refund]
    end
    factory :outdate_order do
      status Order.statuses[:outdate]
    end
  end
end
