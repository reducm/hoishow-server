# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket do
    area_id 1 
    show_id 1
    price 9.99
    order_id 1
    code "MyString" + Random.rand(1...999).to_s
    code_valid_time Time.now
    association :area
    association :show
    association :order
  end
end
