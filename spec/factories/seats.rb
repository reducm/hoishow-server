# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :seat do
    name 'x排x座'

    trait :avaliable do
      status 0
    end

    trait :locked do
      status 1
    end

    trait :unused do
      status 2
    end

    factory :avaliable_seat, traits: [:avaliable]
  end
end
