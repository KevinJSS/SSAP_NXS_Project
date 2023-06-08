class CreateActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :activities do |t|
      t.integer :worked_hours, null: false
      t.date :date, null: false

      t.timestamps
    end
  end
end
