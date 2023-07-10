class AddStageStatusToProjects < ActiveRecord::Migration[7.0]
  def change
    add_column :projects, :stage_status, :integer, null: false, default: 0
  end
end
