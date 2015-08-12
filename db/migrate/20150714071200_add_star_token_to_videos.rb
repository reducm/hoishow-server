class AddStarTokenToVideos < ActiveRecord::Migration
  def up 
    add_column :videos, :star_token, :string
  end

  def down 
    remove_column :videos, :star_token
  end
end
