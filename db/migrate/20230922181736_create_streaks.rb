class CreateStreaks < ActiveRecord::Migration[6.1]
  def change
    create_table :streaks do |t|
      t.references :user, null: false, foreign_key: true
      t.date :start_date, null: false
      t.date :end_date
      t.date :last_incremented
      t.integer :streak_count

      t.timestamps
    end
  end
end
