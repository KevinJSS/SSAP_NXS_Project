class AddHoursToPhasesActivities < ActiveRecord::Migration[7.0]
  def change
    add_column :phases_activities, :hours, :integer, null: false, default: 0
  end
end
