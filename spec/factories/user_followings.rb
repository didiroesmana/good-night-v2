FactoryBot.define do
  factory :user_following do
    association :follower, factory: :user
    association :followed, factory: :user
  end
end