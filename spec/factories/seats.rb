# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :seat do
    row { rand(1..10) }
    column { rand(1..10) }
    name "#{row}排#{column}座"
    price { rand(100..500) }

    trait :row do
      row { rand(1..10) }
    end

    trait :column do
      column { rand(1..10) }
    end

    trait :avaliable do
      status 'avaliable'
    end

    trait :locked do
      status 'locked'
    end

    trait :unused do
      status 'unused'
    end

    factory :avaliable_seat, traits: [:avaliable]
    factory :locked_seat, traits: [:locked]
    factory :unused_seat, traits: [:unused]
  end
end
