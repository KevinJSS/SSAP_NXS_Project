class RemovePhaseIdFromActivities < ActiveRecord::Migration[7.0]
  def change
    remove_index :activities, :phase_id # Remove the index
    remove_column :activities, :phase_id
  end
end
