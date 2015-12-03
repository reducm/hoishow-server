class AddCoverAndRemovedAndIsTopToBoomPlaylists < ActiveRecord::Migration
  def change
    add_column :boom_playlists, :cover, :string
    add_column :boom_playlists, :removed, :boolean
    add_column :boom_playlists, :is_top, :boolean
  end
end
