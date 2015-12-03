class CreatePageLocations < ActiveRecord::Migration
  def change
    create_table :page_locations do |t|
      t.string :boom_id
      t.string :boom_music_top_id
      t.string :boom_location_id
      t.boolean :removed

      t.timestamps null: false
    end

    add_index :page_locations, :boom_id
  end
end
