class AddTableNameToChangeLog < ActiveRecord::Migration[7.0]
  def change
    add_column :change_logs, :table_name, :string, null: false
  end
end
