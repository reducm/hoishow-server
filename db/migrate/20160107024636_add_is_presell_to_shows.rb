class AddIsPresellToShows < ActiveRecord::Migration
  def change
    add_column :shows, :is_presell, :boolean, default: false
  end
end
