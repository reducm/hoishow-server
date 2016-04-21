# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :city_source do
    sequence(:name){|n| "#{Faker::Name.name} #{n}"}
    sequence(:code){|n| n}
    sequence(:yl_fconfig_id){|n| n}
    source CitySource.sources["yongle"]
    association :city
  end
end
