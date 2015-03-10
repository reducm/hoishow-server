# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :comment do
    type_mode "MyString"
    type_mode_id 1
    content "MyString"
    useer ""
  end
end
