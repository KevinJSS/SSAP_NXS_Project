class AddAuthorToChangeLog < ActiveRecord::Migration[7.0]
  def change
    add_column :change_logs, :author, :string, null: false
  end
end
