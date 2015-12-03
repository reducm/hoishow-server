class CreateUserTrackRelations < ActiveRecord::Migration
  def change
    create_table :user_track_relations do |t|
      t.integer :user_id
      t.integer :boom_track_id
      t.integer :play_count

      t.timestamps null: false
    end

    add_index :user_track_relations, :user_id
    add_index :user_track_relations, :boom_track_id
  end
end
