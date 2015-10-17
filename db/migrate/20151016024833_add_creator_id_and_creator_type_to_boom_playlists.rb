class AddCreatorIdAndCreatorTypeToBoomPlaylists < ActiveRecord::Migration
  def change
    add_column :boom_playlists, :creator_id, :integer
    add_column :boom_playlists, :creator_type, :string
  end
end
