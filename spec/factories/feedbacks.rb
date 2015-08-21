# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :feedback do
    content {Faker::Company.bs}
    mobile {Faker::PhoneNumber.phone_number}
  end
end
