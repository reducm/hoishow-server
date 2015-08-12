FactoryGirl.define do
  factory :concert do
    name {Faker::Name.name}
    description {Faker::Name.name}
    start_date {Time.now - 2.weeks}
    end_date {Time.now - 1.weeks}
    status "voting"
    poster "aslkdfalksdlkj"
    is_show "showing"
  end
end
