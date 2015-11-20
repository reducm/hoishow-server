class AddIsDefaultToBoomPlaylists < ActiveRecord::Migration
  def change
    add_column :boom_playlists, :is_default, :boolean, default: false
  end
end
