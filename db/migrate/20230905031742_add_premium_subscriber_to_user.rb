class AddPremiumSubscriberToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :premium_subscriber, :string
  end
end
