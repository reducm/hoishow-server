class CreateEvents < ActiveRecord::Migration
  def change
    create_table :events do |t|
      t.integer :show_id
      t.datetime :show_time
      t.string :stadium_map
      t.string :coordinate_map

      t.timestamps null: false
    end
    add_index :events, :show_id
  end
end
