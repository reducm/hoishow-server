class AddFetchCoverUrlAndFetchFileUrlToBoomTracks < ActiveRecord::Migration
  def change
    add_column :boom_tracks, :fetch_cover_url, :string
    add_column :boom_tracks, :fetch_file_url, :string
  end
end
