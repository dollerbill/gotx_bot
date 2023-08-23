class CreateGames < ActiveRecord::Migration[6.1]
  def change
    create_table :games do |t|
      t.string :title_usa
      t.string :title_eu
      t.string :title_jp
      t.string :title_world
      t.string :title_other
      t.string :year
      t.string :system
      t.string :developer
      t.string :genre
      t.string :img_url
      t.integer :time_to_beat
      t.bigint :screenscraper_id
      t.timestamps
    end
  end
end
