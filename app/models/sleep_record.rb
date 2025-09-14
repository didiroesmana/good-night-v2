class SleepRecord < ApplicationRecord
  belongs_to :user

  MIN_SLEEP_DURATION_IN_MINUTES = 1.minute

  validates :sleep_time, presence: true
  validate :wake_time_after_sleep_time, if: -> { sleep_time.present? && wake_time.present? }
  validate :minimum_sleep_duration, if: -> { sleep_time.present? && wake_time.present? }

  scope :latest_active, -> { where(wake_time: nil).order(sleep_time: :desc).limit(1) }
  scope :completed, -> { where.not(wake_time: nil) }

  before_save :calculate_sleep_length, if: -> { sleep_time.present? && wake_time.present? }
  after_update :enqueue_daily_summary_job, if: -> { saved_change_to_wake_time? && completed? }

  def active?
    wake_time.nil?
  end

  def completed?
    !active?
  end

  private def wake_time_after_sleep_time
    return unless wake_time <= sleep_time

    errors.add(:wake_time, "must be after sleep time")
  end

  private def minimum_sleep_duration
    duration = wake_time - sleep_time
    return unless duration < MIN_SLEEP_DURATION_IN_MINUTES

    errors.add(:wake_time, "sleep duration must be at least #{MIN_SLEEP_DURATION_IN_MINUTES / 60} minutes")
  end

  private def calculate_sleep_length
    self.sleep_length_in_minutes = ((wake_time - sleep_time) / 1.minute).round
  end

  private def enqueue_daily_summary_job
    PopulateDailySleepSummaryJob.perform_later(user_id, self.id)
  end
end
