class CreateSubscriptions < ActiveRecord::Migration[6.1]
  def change
    create_table :subscriptions do |t|
      t.timestamps
      t.references :user, null: false, foreign_key: true
      t.string :subscription_type
      t.date :start_date, null: false
      t.date :end_date
      t.date :last_subscribed
      t.integer :subscribed_months, default: 0
    end
  end
end
