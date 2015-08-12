FactoryGirl.define do
  factory :comment do
    content Base64.encode64("fuck you")
    creator_type "Star"
    creator_id 1
    association :topic
    parent_id nil
  end
end
