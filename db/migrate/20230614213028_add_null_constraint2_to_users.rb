class AddNullConstraint2ToUsers < ActiveRecord::Migration[7.0]
  def change
    change_column_null :users, :job_position, false
  end
end
