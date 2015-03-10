# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stadium do
    name "MyString"
    address "MyString"
    longitude "9.99"
    latitude "9.99"
    city nil
  end
end
