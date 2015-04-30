class AddVideoToVideos < ActiveRecord::Migration
  def up
    add_column :videos, :video, :string
  end

  def down 
    remove_column :videos, :video
  end
end
