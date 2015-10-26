class AddCoverAndIsTopToBoomTracks < ActiveRecord::Migration
  def change
    add_column :boom_tracks, :cover, :string
    add_column :boom_tracks, :is_top, :boolean
  end
end
