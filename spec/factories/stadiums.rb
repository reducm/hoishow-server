# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :stadium do
    association :city
    pic "fuck jassssss"
    name {Faker::Name.name}
    address {Faker::Address.street_address}
    longitude {Faker::Address.longitude}
    latitude {Faker::Address.latitude}
  end
end
