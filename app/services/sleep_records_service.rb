class SleepRecordsService
  def initialize(user, limit: 10)
    @user = user
    @limit = limit
  end

  def clock_in!
    if @user.sleep_records.latest_active.present?
      raise SleepRecordErrors::CannotClockInForSleepWithActiveRecord, "Cannot clock in for sleep while having an active sleep record"
    end

    @user.sleep_records.create!(sleep_time: Time.current)
    ordered_sleep_records
  rescue ActiveRecord::RecordInvalid => e
    raise SleepRecordErrors::InvalidSleepRecord, "Failed to create sleep record: #{e.message}"
  end

  def clock_out!
    latest_active = @user.sleep_records.latest_active

    unless latest_active.present?
      raise SleepRecordErrors::CannotClockOutWithoutActiveRecord, "Cannot clock out without an active sleep record"
    end

    active_record = latest_active.first
    wake_time = Time.current
    active_record.update!(wake_time: wake_time)

    active_record.reload
  rescue ActiveRecord::RecordInvalid => e
    raise SleepRecordErrors::InvalidSleepRecord, "Failed to update sleep record: #{e.message}"
  end

  private def ordered_sleep_records
    @user.sleep_records.order(sleep_time: :desc).limit(@limit)
  end
end