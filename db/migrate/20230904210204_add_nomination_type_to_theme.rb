class AddNominationTypeToTheme < ActiveRecord::Migration[6.1]
  def change
    add_column :themes, :nomination_type, :string, default: 'gotm'
  end
end
