class CreateChangeLogs < ActiveRecord::Migration[7.0]
  def change
    create_table :change_logs do |t|
      t.integer :table_id, null: false
      t.integer :user_id, null: false
      t.text :description, null: false

      t.timestamps
    end
  end
end
