FactoryGirl.define do
  factory :folder do
    sequence(:name){|n| "收藏夹#{n}"}
    sequence(:desc){|n| "收藏夹#{n} 描述"}
  end
end

