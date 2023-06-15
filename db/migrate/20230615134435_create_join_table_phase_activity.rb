class CreateJoinTablePhaseActivity < ActiveRecord::Migration[7.0]
  def change
    create_join_table :phases, :activities do |t|
       t.index [:phase_id, :activity_id]
       t.index [:activity_id, :phase_id]
    end
  end
end
