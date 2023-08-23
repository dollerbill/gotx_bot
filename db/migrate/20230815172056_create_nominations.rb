class CreateNominations < ActiveRecord::Migration[6.1]
  def change
    create_table :nominations do |t|
      t.string :nomination_type, null: false
      t.string :description
      t.boolean :winner, default: false
      t.references :game
      t.references :user
      t.references :theme
      t.timestamps
    end
  end
end
