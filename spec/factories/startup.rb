# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :startup do
    id 1
    pic { fixture_file_upload(File.join Rails.root, %w(spec fixtures about.png)) }
    valid_time 8964
  end
end
