# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :concert do
    name {Faker::Name.name}
    description {Faker::Name.name}
    start_date {Time.now - 2.weeks}
    end_date {Time.now - 1.weeks}
    status 0
    poster "aslkdfalksdlkj"
  end
end
