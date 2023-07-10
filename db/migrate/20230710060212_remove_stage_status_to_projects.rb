class RemoveStageStatusToProjects < ActiveRecord::Migration[7.0]
  def change
    remove_column :projects, :stage_status, :integer, null: false, default: 0
  end
end
