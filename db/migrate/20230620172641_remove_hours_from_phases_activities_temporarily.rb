class RemoveHoursFromPhasesActivitiesTemporarily < ActiveRecord::Migration[7.0]
  def change
    remove_column :phases_activities, :hours
  end
end
