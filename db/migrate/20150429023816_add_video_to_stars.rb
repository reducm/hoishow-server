class AddVideoToStars < ActiveRecord::Migration
  def up 
    add_column :stars, :video, :string
  end
  def down 
    remove_column :stars, :video
  end
end
