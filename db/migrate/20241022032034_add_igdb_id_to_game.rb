class AddIgdbIdToGame < ActiveRecord::Migration[7.1]
  def change
    add_column :games, :igdb_id, :bigint
  end
end
