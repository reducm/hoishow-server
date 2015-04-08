# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :ticket do
    area nil
    show nil
    price "9.99"
    order nil
    code "MyString"
    code_valid_time "2015-04-08 16:49:44"
  end
end
