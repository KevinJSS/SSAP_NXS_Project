class RemoveForeignKeyFromActivities < ActiveRecord::Migration[7.0]
  def change
    remove_foreign_key :activities, :phases
  end
end
