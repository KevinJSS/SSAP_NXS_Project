class AddColumnToActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :activities, :nested_phases, :boolean, default: false
  end
end
