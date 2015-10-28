class AddSourceToShows < ActiveRecord::Migration
  def up 
    add_column :shows, :source, :integer, default: 0
  end

  def down
    remove_column :shows, :source 
  end
end
