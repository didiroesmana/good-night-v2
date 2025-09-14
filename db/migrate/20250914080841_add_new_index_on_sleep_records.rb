class AddNewIndexOnSleepRecords < ActiveRecord::Migration[8.0]
  def change
    add_index :sleep_records,
              [:user_id, :sleep_time],
              order: { sleep_time: :desc },
              where: "wake_time IS NULL",
              name: "index_sleep_records_on_user_id_and_sleep_time_desc_open"
  end
end
