class AddToRpgAchievementsToCompletion < ActiveRecord::Migration[7.1]
  def change
    add_column :completions, :rpg_achievements, :boolean, default: false
  end
end
