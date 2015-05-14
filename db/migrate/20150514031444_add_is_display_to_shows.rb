class AddIsDisplayToShows < ActiveRecord::Migration
  def up
    add_column :shows, :is_display, :boolean, default: true
  end
  
  def down 
    remove_column :shows, :is_display, :boolean
  end
end
