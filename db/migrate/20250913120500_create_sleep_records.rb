class CreateSleepRecords < ActiveRecord::Migration[8.0]
  def change
    create_table :sleep_records, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.datetime :sleep_time
      t.datetime :wake_time
      t.integer :sleep_length_in_minutes

      t.timestamps

      t.index  [:user_id, :sleep_time], unique: true
    end
  end
end
