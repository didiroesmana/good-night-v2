FactoryBot.define do
  factory :sleep_record do
    user
    sleep_time { Time.current }
    wake_time { nil }
    sleep_length_in_minutes { nil }

    trait :completed do
      sequence(:sleep_time) { |n| Time.current - n.days }
      wake_time { sleep_time + 8.hours }
      sleep_length_in_minutes { 480 }
    end

    trait :active do
      wake_time { nil }
      sleep_length_in_minutes { nil }
    end
  end
end