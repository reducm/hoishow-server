# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_message_relation do
    user :user
    message :message
    is_new :true
  end
end
