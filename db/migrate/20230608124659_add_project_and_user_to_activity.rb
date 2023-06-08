class AddProjectAndUserToActivity < ActiveRecord::Migration[7.0]
  def change
    add_reference :activities, :project, null: false, foreign_key: true
    add_reference :activities, :user, null: false, foreign_key: true
  end
end
