class CreateProjects < ActiveRecord::Migration[7.0]
  def change
    create_table :projects do |t|
      t.string :name, null: false
      t.date :start_date, null: false
      t.date :scheduled_deadline
      t.text :location
      t.integer :stage, null: false

      t.timestamps
    end
  end
end
