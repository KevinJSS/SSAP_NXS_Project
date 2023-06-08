class AddProjectToMinute < ActiveRecord::Migration[7.0]
  def change
    add_reference :minutes, :project, null: false, foreign_key: true
  end
end
