class AddAccountNumberToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :account_number, :string
  end
end
