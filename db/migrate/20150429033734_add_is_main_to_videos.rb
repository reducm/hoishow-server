class AddIsMainToVideos < ActiveRecord::Migration
  def up 
    add_column :videos, :is_main, :boolean
  end
  
  def down 
    remove_column :videos, :is_main
  end
end
