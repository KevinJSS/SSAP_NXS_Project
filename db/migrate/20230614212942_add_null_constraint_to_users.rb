class AddNullConstraintToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :address, false
  end
end
