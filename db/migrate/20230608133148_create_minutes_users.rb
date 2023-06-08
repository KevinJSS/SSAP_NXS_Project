class CreateMinutesUsers < ActiveRecord::Migration[7.0]
  def change
    create_table :minutes_users do |t|
      t.references :minute, null: false, foreign_key: true
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end
  end
end
