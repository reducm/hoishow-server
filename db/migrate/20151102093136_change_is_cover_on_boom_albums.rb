class ChangeIsCoverOnBoomAlbums < ActiveRecord::Migration
  def up
    change_column :boom_albums, :is_cover, :boolean, default: false
  end

  def down 
    change_column :boom_albums, :is_cover, :boolean, default: true 
  end
end
