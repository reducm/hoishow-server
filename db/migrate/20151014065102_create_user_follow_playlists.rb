class CreateUserFollowPlaylists < ActiveRecord::Migration
  def change
    create_table :user_follow_playlists do |t|
      t.integer :user_id
      t.integer :boom_playlist_id

      t.timestamps null: false
    end

    add_index :user_follow_playlists, :user_id
    add_index :user_follow_playlists, :boom_playlist_id
  end
end
