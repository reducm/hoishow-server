class CreateBoomPlaylists < ActiveRecord::Migration
  def change
    create_table :boom_playlists do |t|
      t.string :name
      t.integer :mode

      t.timestamps null: false
    end
  end
end
