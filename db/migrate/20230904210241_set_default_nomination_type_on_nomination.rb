class SetDefaultNominationTypeOnNomination < ActiveRecord::Migration[6.1]
  def change
    change_column :nominations, :nomination_type, :string, default: 'gotm'
  end
end
