module V1
  class DailySleepSummarySerializer < ActiveModel::Serializer
    attributes :id, :user_id, :date, :total_sleep_length_in_minutes

    def date
      object.date.iso8601
    end
  end
end