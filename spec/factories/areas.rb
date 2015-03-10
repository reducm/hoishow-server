# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :area do
    name "MyString"
    seats_count 1
    stadium nil
  end
end
