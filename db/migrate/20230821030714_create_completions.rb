class CreateCompletions < ActiveRecord::Migration[6.1]
  def change
    create_table :completions do |t|
      t.datetime :completed_at, null: false
      t.references :nomination
      t.references :user
      t.timestamps
    end
  end
end
