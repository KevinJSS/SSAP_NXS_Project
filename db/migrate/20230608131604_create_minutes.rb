class CreateMinutes < ActiveRecord::Migration[7.0]
  def change
    create_table :minutes do |t|
      t.string :meeting_title, null: false
      t.date :meeting_date, null: false
      t.time :start_time, null: false
      t.time :end_time, null: false
      t.text :meeting_objectives
      t.text :discussed_topics
      t.text :pending_topics
      t.text :agreements
      t.text :meeting_notes

      t.timestamps
    end
  end
end
