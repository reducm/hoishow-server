class AddIsHotToBoomTags < ActiveRecord::Migration
  def change
    add_column :boom_tags, :is_hot, :boolean
  end
end
