# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :city do
    pinyin {Faker::Name.name}
    sequence(:name){|n| "#{Faker::Name.name} #{n}"}
    sequence(:code){|n| n}
  end
end
