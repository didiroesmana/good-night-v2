FactoryBot.define do
  factory :daily_sleep_summary do
    association :user
    date { Date.current }
    total_sleep_length_in_minutes { 480 } # 8 hours default
  end
end