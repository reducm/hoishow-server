# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket do
    area_id 1 
    show_id 1
    price "9.99"
    order_id 1
    code "MyString"
    code_valid_time "2015-04-08 16:49:44"
    association :area
    association :show
    association :order
  end
end
