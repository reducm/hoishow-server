# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    mobile "MyString"
    email "MyString"
    encrypted_password "MyString"
    last_sign_in_at "2015-03-10 16:32:22"
    avatar "MyString"
    nickname "MyString"
    sex 1
    birthday "2015-03-10 16:32:22"
    salt "MyString"
    has_set_password false
  end
end
