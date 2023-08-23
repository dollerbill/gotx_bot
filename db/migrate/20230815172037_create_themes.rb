class CreateThemes < ActiveRecord::Migration[6.1]
  def change
    create_table :themes do |t|
      t.date :creation_date, null: false
      t.string :title, null: false
      t.string :description
      t.timestamps
    end
  end
end
