# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    send_type "new_concert"
    notification_text "hahaha"
    title "MyString"
    content "MyText"
    subject_type "MyString"
    subject_id 1
    creator_type "MyString"
    creator_id 1
    task_id "akfwhehfasdnkhnsdf"
  end
end
