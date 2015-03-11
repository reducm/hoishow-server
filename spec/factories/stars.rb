# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :star do
    name {Faker::Name.name}
    avatar "MyString"
  end
end
