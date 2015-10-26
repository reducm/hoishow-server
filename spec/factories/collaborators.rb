# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :collaborator do
    name {Faker::Name.name}
    email {Faker::Internet.email}
    weibo {Faker::Name.name}
    wechat {Faker::Name.name}
    cover { fixture_file_upload(File.join Rails.root, %w(spec fixtures about.png)) }
    verified true
  end
end
