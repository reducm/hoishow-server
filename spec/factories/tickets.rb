# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket do
    area_id 1 
    show_id 1
    price 9.99
    order_id 1
    admin_id 1
    checked_at Time.now + Random.rand(1..99).minutes
    code "MyString" + Random.rand(1...999).to_s
    code_valid_time Time.now
    association :area
    association :show
    association :order
    factory :used_ticket do
      status Ticket.statuses[:used]
    end

  end
end
