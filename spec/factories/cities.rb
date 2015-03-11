# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :city do
    pinyin {Faker::Name.name}
    name {Faker::Name.name}
    sequence(:code){|n| n}
  end
end
