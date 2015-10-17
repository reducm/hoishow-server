class CreateActivityTrackRelations < ActiveRecord::Migration
  def change
    create_table :activity_track_relations do |t|
      t.integer :boom_activity_id
      t.integer :boom_track_id

      t.timestamps null: false
    end
  end
end
