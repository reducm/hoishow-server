# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :concert_city_relation do
    concert :concert
    city :city
    base_number 0
  end
end
