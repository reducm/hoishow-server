# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :message do
    send_type "new_concert"
    notification_text "hahaha"
    title "MyString"
    content "MyText"
    subject_type "Star"
    subject_id 1
    creator_type "Star"
    creator_id 1
    task_id "akfwhehfasdnkhnsdf"
    factory :reply_message do
      subject_type "Topic"
    end
    factory :system_message do
      subject_type "Star"
    end
  end
end
