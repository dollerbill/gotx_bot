class CreateUsers < ActiveRecord::Migration[6.1]
  def change
    create_table :users do |t|
      t.string :name, null: false
      t.bigint :discord_id
      t.string :old_discord_name
      t.integer :current_points, default: 0
      t.integer :redeemed_points, default: 0
      t.integer :earned_points, default: 0
      t.integer :premium_points, default: 0
      t.timestamps
    end
  end
end
