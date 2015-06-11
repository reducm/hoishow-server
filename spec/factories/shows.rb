FactoryGirl.define do
  factory :show do
    name {Faker::Name.name}
    min_price 1.0
    max_price 10.0
    description "asaksdkajsdkj"
    poster "aksfkjlasbdfkljasdlkfbksj"
    show_time {Time.now + 1.weeks}
    association :concert
    association :stadium
    association :city
    status "selling"
    mode "voted_users"
    is_display true
  end
end
