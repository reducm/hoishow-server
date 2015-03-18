# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :star do
    name {Faker::Name.name}
    avatar { fixture_file_upload(File.join Rails.root, %w(spec fixtures about.png)) }
  end
end
