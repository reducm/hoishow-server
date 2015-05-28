class AddIsTopToConcerts < ActiveRecord::Migration
  def up 
    add_column :concerts, :is_top, :boolean, default: false 
  end

  def down 
    remove_column :concerts, :is_top 
  end
end
