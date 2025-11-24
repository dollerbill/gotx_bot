class CreateApiTokens < ActiveRecord::Migration[8.0]
  def change
    create_table :api_tokens do |t|
      t.string :provider, null: false
      t.text :access_token, null: false
      t.datetime :expires_at

      t.timestamps
    end

    add_index :api_tokens, :provider, unique: true
  end
end
