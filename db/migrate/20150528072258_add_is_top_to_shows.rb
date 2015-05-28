class AddIsTopToShows < ActiveRecord::Migration
  def up 
    add_column :shows, :is_top, :boolean, default: false 
  end

  def down 
    remove_column :shows, :is_top 
  end
end
