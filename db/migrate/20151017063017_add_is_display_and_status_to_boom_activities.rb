class AddIsDisplayAndStatusToBoomActivities < ActiveRecord::Migration
  def change
    add_column :boom_activities, :status, :integer
    add_column :boom_activities, :is_display, :boolean
  end
end
