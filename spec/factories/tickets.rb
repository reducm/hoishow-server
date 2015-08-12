# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket do
    price 9.99
    admin_id 1
    checked_at Time.now + Random.rand(1..99).minutes
    code "MyString" + Random.rand(1...999).to_s
    code_valid_time Time.now
    association :area
    association :show
    association :order

    trait :has_seat_name do
      seat_name 'x排x座'
    end

    factory :used_ticket do
      status Ticket.statuses[:used]
    end

    factory :selectable_tickets, traits: [:has_seat_name]

  end
end
