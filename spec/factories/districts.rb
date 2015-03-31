# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :district do
    name {Faker::Name.name}
    association :city
  end
end
