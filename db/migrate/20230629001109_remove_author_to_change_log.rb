class RemoveAuthorToChangeLog < ActiveRecord::Migration[7.0]
  def change
    remove_column :change_logs, :author, :string, null: false
  end
end
