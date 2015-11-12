class AddIsHotToBoomActivities < ActiveRecord::Migration
  def up 
    add_column :boom_activities, :is_hot, :boolean
  end

  def down
    remove_column :boom_activities, :is_hot
  end
end
