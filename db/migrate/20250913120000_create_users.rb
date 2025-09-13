class CreateUsers < ActiveRecord::Migration[8.0]
  def change
    create_table :users, id: :bigint do |t|
      t.string :name

      t.timestamps
    end

    add_index :users, :name
  end
end
