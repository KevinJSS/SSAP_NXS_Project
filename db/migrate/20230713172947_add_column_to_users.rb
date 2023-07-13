class AddColumnToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :new_admin, :boolean, default: false
  end
end
