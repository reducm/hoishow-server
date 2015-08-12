class AddDescriptionToShows < ActiveRecord::Migration
  def up
    add_column :shows, :description, :text
  end

  def down
    remove_column :shows, :description
  end
 
end
