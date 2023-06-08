class AddUserToEmergencyContact < ActiveRecord::Migration[7.0]
  def change
    add_reference :emergency_contacts, :user, null: false, foreign_key: true
  end
end
