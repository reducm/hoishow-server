class AddMultiColumnsToBoomTracks < ActiveRecord::Migration
  def change
    add_column :boom_tracks, :boom_playlist_id, :integer
    add_column :boom_tracks, :creator_id, :integer
    add_column :boom_tracks, :creator_type, :string
    add_column :boom_tracks, :artists, :string
  end
end
