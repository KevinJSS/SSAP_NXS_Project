class RemoveNullConstraintFromAddress < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :address, true
  end
end
