FactoryGirl.define do
  factory :user do
    sequence(:name){|n| "user#{n}"}
    sequence(:email){|n| "user#{n}@test.com"}
    password "123456"
  end
end
