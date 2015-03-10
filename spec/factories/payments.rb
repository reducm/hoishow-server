# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :payment do
    purchase_id 1
    purchase_type "MyString"
    payment_type "MyString"
    status 1
    trade_id "MyString"
    pay_at "2015-03-10 15:33:30"
    refund_at "2015-03-10 15:33:30"
    amount "9.99"
    refund_amount "9.99"
    paid_origin "MyString"
    order nil
  end
end
