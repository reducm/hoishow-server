class AddDescriptionToStars < ActiveRecord::Migration
  def up 
    add_column :stars, :description, :text
  end

  def down 
    remove_column :stars, :description
  end
end
