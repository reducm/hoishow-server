class AddIsDisplayToBoomPlaylists < ActiveRecord::Migration
  def change
    add_column :boom_playlists, :is_display, :boolean, default: false
  end
end
