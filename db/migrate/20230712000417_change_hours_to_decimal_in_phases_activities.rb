class ChangeHoursToDecimalInPhasesActivities < ActiveRecord::Migration[7.0]
  def change
    change_column :phases_activities, :hours, :decimal, precision: 5, scale: 1
  end
end
