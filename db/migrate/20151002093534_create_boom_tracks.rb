class CreateBoomTracks < ActiveRecord::Migration
  def change
    create_table :boom_tracks do |t|
      t.string :boom_id
      t.string :boom_activity_id
      t.string :name
      t.string :publisher
      t.string :file
      t.decimal :duration, precision: 12, scale: 6
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :boom_tracks, :boom_id
  end
end
