# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    mobile do
      mobile = "137"
      mobile + 8.times.map{rand(9).to_s}.join("")
    end
    email {Faker::Internet.email}
    #encrypted_password "MyString"
    last_sign_in_at {Time.now - 1.weeks}
    avatar "MyString"
    nickname {Faker::Name.name}
    sex 1
    birthday Time.now
    salt "MyString"
    #has_set_password false
  end
end
