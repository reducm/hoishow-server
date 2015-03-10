# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :show do
    min_pirce "9.99"
    max_price "9.99"
    poster "MyString"
    show_time ""
    concert nil
  end
end
