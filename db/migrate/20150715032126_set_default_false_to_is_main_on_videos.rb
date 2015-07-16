class SetDefaultFalseToIsMainOnVideos < ActiveRecord::Migration
  def change
    change_column :videos, :is_main, :boolean, default: false
  end
end
