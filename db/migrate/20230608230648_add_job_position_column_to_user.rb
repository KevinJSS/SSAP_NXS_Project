class AddJobPositionColumnToUser < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :job_position, :string
  end
end
