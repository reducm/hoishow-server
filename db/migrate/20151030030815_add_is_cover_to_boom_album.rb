class AddIsCoverToBoomAlbum < ActiveRecord::Migration
  def up 
    add_column :boom_albums, :is_cover, :boolean, default: true 
  end

  def down
    remove_column :boom_albums, :is_cover 
  end
end
