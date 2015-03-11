# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :show_area_relation do
    show :show
    area :area
    price {Random.rand(10..100)}
  end
end
