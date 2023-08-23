class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.bigint :discord_id
      t.string :old_discord_name
      t.float :current_points, default: 0
      t.float :redeemed_points, default: 0
      t.float :earned_points, default: 0
      t.float :premium_points, default: 0
      t.timestamps
    end
  end
end
