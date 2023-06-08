class AddAdditionalAttributesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :id_card, :string, null:false
    add_column :users, :fullname, :string, null:false
    add_column :users, :phone, :string, null:false
    add_column :users, :address, :string, null:false
    add_column :users, :role, :integer, null:false
  end
end
