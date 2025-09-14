module SleepRecordErrors
  class Error < StandardError; end
  class CannotClockInForSleepWithActiveRecord < Error; end
  class CannotClockOutWithoutActiveRecord < Error; end
  class InvalidSleepRecord < Error; end
end