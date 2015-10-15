# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :api_auth do
    key "MyString"
    user "MyString"
    secretcode "MyString"
  end
end
