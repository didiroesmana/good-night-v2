class PopulateDailySleepSummaryJob < ApplicationJob
  queue_as :default

  def perform(user_id, sleep_record_id)
    user = User.find(user_id)
    sleep_record = SleepRecord.find(sleep_record_id)

    return  unless user && sleep_record

    begin
      sleep_summary = DailySleepSummary.find_or_initialize_by(user_id: user.id, date: sleep_record.sleep_time.to_date)

      total_sleep_length_in_minutes = user.sleep_records.completed.where(sleep_time: sleep_record.sleep_time.all_day).sum(&:sleep_length_in_minutes)
      sleep_summary.update!(
        total_sleep_length_in_minutes: total_sleep_length_in_minutes,
      )
    rescue ActiveRecord::RecordInvalid => e
      Rails.logger.error "PopulateDailySleepSummaryJob failed: #{e.message}"
      raise
    end
  rescue StandardError => e
    Rails.logger.error "PopulateDailySleepSummaryJob failed: #{e.message}"
    raise
  end
end