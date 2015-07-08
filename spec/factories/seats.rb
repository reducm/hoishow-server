# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :seat do
    row { rand(1..10) }
    column { rand(1..10) }
    name "x排x座"
    price { rand(100..500) }

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
    factory :locked_seat, traits: [:locked]
    factory :unused_seat, traits: [:unused]
  end
end
