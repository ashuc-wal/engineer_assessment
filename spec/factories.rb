FactoryBot.define do
  factory :user do
    sequence(:email) { |n| "foo#{n}@bar.com"}
    password "123456"
  end

  factory :post do
    association :user

    title "Post title"
    sequence(:url) { |n| "http://localhost:300#{n}/post-title" }
  end
end
