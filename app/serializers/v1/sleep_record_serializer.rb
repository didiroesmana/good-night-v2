module V1
  class SleepRecordSerializer < ActiveModel::Serializer
    attributes :id, :created_at, :wake_time, :sleep_time, :sleep_length_in_minutes

    def sleep_time
      object.sleep_time&.iso8601
    end

    def wake_time
      object.wake_time&.iso8601
    end

    def sleep_length_in_minutes
      object.sleep_length_in_minutes
    end
  end
end