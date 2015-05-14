# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :banner do
    association :admin
    poster "MyString"
    subject_type "Star"
    subject_id 1
    description "MyText"
    factory :article_banner do
      subject_type "Article"
      description "http://www.163.com"
    end
  end
end
