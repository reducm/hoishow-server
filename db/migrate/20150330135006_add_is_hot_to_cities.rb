class AddIsHotToCities < ActiveRecord::Migration
  def up 
    add_column :cities, :is_hot, :boolean
  end

  def down
    remove_column :cities, :is_hot
  end


end
