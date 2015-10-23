# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :boom_admin do
    email "MyString"
    name "MyString"
    encrypted_password "MyString"
    salt "MyString"
    last_sign_in_at "2015-10-23 15:43:59"
    admin_type 1
    is_block false
    api_token "MyString"
  end
end
