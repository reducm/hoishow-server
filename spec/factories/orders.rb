# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :order do
    amount "9.99"
    concert_name "MyString"
    stadium_name "MyString"
    area_name "MyString"
    valid_time "MyString"
    out_id "MyString"
    city_name "MyString"
    star_name "MyString"
    user nil
    concert_id 1
    city_id 1
    stadium_id 1
    star_id 1
    area_id 1
    show_id 1
  end
end
