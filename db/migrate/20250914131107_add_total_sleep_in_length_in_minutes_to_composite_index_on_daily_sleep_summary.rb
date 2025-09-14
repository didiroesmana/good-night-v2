class AddTotalSleepInLengthInMinutesToCompositeIndexOnDailySleepSummary < ActiveRecord::Migration[8.0]
  def change
    add_index :daily_sleep_summaries,
          [:user_id, :date, :total_sleep_length_in_minutes],
          order: { total_sleep_length_in_minutes: :desc },
          name: "index_sleep_summaries_user_date_length"
  end
end
