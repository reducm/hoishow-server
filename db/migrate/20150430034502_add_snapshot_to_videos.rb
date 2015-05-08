class AddSnapshotToVideos < ActiveRecord::Migration
  def up
    add_column :videos, :snapshot, :string
  end
  
  def down 
    remove_column :videos, :snapshot
  end
end
