# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :show do
    name {Faker::Name.name}
    min_pirce 1.0
    max_price 10.0
    poster "MyString"
    show_time {Time.now + 1.weeks}
    concert :concert
    stadium :stadium
  end
end
