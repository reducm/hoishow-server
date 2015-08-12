FactoryGirl.define do
  factory :show do
    name {Faker::Name.name}
    min_price 1.0
    max_price 10.0
    description "asaksdkajsdkj"
    poster { fixture_file_upload(File.join Rails.root, %w(spec fixtures about.png)) }
    ticket_pic { fixture_file_upload(File.join Rails.root, %w(spec fixtures about.png)) }
    stadium_map { fixture_file_upload(File.join Rails.root, %w(spec fixtures about.png)) }
    show_time {Time.now + 1.weeks}
    association :concert
    association :stadium
    association :city
    status "selling"
    mode "voted_users"
    is_display true
    description_time Date.today.to_s
  end
end
