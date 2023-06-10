class ChangeStageStatusType < ActiveRecord::Migration[7.0]
  def change
    change_column :projects, :stage_status, :integer
  end
end
