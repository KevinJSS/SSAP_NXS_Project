class RemoveWorkedHoursFromActivities < ActiveRecord::Migration[7.0]
  def change
    remove_column :activities, :worked_hours
  end
end
