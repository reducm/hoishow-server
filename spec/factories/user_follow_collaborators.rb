# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user_follow_collaborator do
    user :user
    collaborator :collaborator
  end
end
