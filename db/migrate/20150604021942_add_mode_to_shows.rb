class AddModeToShows < ActiveRecord::Migration
  def up
    add_column :shows, :mode, :integer
  end

  def down 
    remove_column :shows, :mode
  end
end
