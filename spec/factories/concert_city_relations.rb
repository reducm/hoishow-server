# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :concert_city_relation do
    concert :concert
    city :city
  end
end
