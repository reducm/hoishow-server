class RenameVideoToSourceOnVideos < ActiveRecord::Migration
  def change
    rename_column :videos, :video, :source
  end
end
