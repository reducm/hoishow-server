FactoryGirl.define do
  factory :admin do
    email "MyString"
    admin_type 0
    name {Faker::Name.name}
    encrypted_password "sha1:oZVXi9YEwM+1ALyFIPA8Zc+KNZsoK6fd\n"
    salt "gtXTUNfxsPc6xuWZqz/m7RK+4geGBnAX"
    last_sign_in_at Time.now
    api_token "123"
    factory :operator do
      admin_type 1
    end
    factory :ticket_checker do
      admin_type 2
    end
  end
end
