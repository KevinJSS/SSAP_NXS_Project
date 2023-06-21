class CreatePhasesActivities < ActiveRecord::Migration[7.0]
  def change
    create_table :phases_activities do |t|
      t.references :phase, null: false, foreign_key: true
      t.references :activity, null: false, foreign_key: true
      t.integer :hours, null: false

      t.timestamps
    end
  end
end