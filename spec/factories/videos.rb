# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :video do
    source { fixture_file_upload(File.join Rails.root, %w(spec fixtures video_for_test.mp4)) }
    association :star
  end
end
