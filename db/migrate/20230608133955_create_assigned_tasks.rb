class CreateAssignedTasks < ActiveRecord::Migration[7.0]
  def change
    create_table :assigned_tasks do |t|
      t.string :title, null: false
      t.string :description, null: false
      t.integer :priority, null: false
      t.date :deadline, null: false

      t.timestamps
    end
  end
end
