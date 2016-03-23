# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :event do
    stadium_map { fixture_file_upload(File.join Rails.root, %w(spec fixtures about.png)) }
  end
end
