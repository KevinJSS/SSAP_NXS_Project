class AddAttributesToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :id_card_type, :integer, null: false
    add_column :users, :marital_status, :integer, null: false
    add_column :users, :birth_date, :date, null: false
    add_column :users, :province, :string, null: false
    add_column :users, :canton, :string, null: false
    add_column :users, :district, :string, null: false
    add_column :users, :education, :integer, null: false
  end
end
