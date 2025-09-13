class CreateDailySleepSummaries < ActiveRecord::Migration[8.0]
  def change
    create_table :daily_sleep_summaries, id: :bigint do |t|
      t.references :user, null: false, foreign_key: true, type: :bigint
      t.date :date
      t.integer :total_sleep_length_in_minutes

      t.timestamps

      t.index [:user_id, :date], unique: true
    end
  end
end
