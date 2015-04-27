# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :admin do
    email "MyString"
    admin_type 0
    name "MyString"
    encrypted_password "MyString"
    salt "MyString"
    last_sign_in_at "2015-04-02 15:22:15"
  end
end
