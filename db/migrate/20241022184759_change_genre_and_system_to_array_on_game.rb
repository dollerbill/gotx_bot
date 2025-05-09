class ChangeGenreAndSystemToArrayOnGame < ActiveRecord::Migration[7.1]
  def up
    change_column :games, :genre, :text, array: true, default: [], using: "(string_to_array(genre, ','))"
    rename_column :games, :genre, :genres

    change_column :games, :system, :text, array: true, default: [], using: "(string_to_array(system, ','))"
    rename_column :games, :system, :systems
  end

  def down
    rename_column :games, :genres, :genre
    change_column :games, :genre, :text, array: false, default: nil, using: "(array_to_string(genre, ','))"

    rename_column :games, :systems, :system
    change_column :games, :system, :text, array: false, default: nil, using: "(array_to_string(system, ','))"
  end
end
