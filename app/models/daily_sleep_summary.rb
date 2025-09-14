class DailySleepSummary < ApplicationRecord
  belongs_to :user

  validates :date, presence: true, uniqueness: { scope: :user_id }
  validates :total_sleep_length_in_minutes, presence: true, numericality: { greater_than: 0 }
end
