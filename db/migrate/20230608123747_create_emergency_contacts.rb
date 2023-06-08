class CreateEmergencyContacts < ActiveRecord::Migration[7.0]
  def change
    create_table :emergency_contacts do |t|
      t.string :fullname, null: false
      t.string :phone, null: false

      t.timestamps
    end
  end
end
