class AddIsDisplayToStars < ActiveRecord::Migration
  def up 
    add_column :stars, :is_display, :boolean
  end

  def down 
    remove_column :stars, :is_display
  end
end
