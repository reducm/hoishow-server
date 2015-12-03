class CreatePlaylistTrackRelations < ActiveRecord::Migration
  def change
    create_table :playlist_track_relations do |t|
      t.integer :boom_track_id
      t.integer :boom_playlist_id

      t.timestamps null: false
    end
  end
end
