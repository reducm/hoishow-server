class AddPosterToStars < ActiveRecord::Migration
  def up 
    add_column :stars, :poster, :string
  end

  def down 
    remove_column :stars, :poster
  end
end
