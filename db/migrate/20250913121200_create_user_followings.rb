class CreateUserFollowings < ActiveRecord::Migration[8.0]
  def change
    create_table :user_followings, id: :bigint do |t|
      t.references :follower, null: false, foreign_key: { to_table: :users }, type: :bigint
      t.references :followed, null: false, foreign_key: { to_table: :users }, type: :bigint

      t.timestamps

      t.index [:follower_id, :followed_id], unique: true
      t.index [:followed_id, :follower_id], unique: true
    end
  end
end
